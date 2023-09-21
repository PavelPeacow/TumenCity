//
//  DigWorkViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit
import RxSwift
import Combine

final class DigWorkViewController: UIViewController {
    
    private let viewModel = DigWorkViewModel()
    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Введите адрес..."
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    private lazy var loadingViewController = LoadingViewController()
    
    private lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigationBar()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "Земляные работы"
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    private func setUpNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapFilterIcon))
    }
    
    private func bindSearchController() {
        searchController.searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] str in
                viewModel.searchQuery = str
            })
            .disposed(by: bag)
    }
    
    private func setUpBindings() {
        bindSearchController()
        
        viewModel
            .isLoadingObservable
            .sink { [unowned self] in
                if $0 {
                    loadingViewController.showLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = true
                        navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                } else {
                    loadingViewController.removeLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = false
                        navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            ErrorSnackBar(errorDesciptrion: error.localizedDescription,
                          andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel
            .searchQueryObservable
            .flatMap { [unowned self] query in
                return viewModel.findAnnotationByAddressName(String(query))
            }
            .sink { [unowned self] annotation in
                if let annotation{
                    map.moveCameraToAnnotation(annotation)
                } else {
                    map.setDefaultRegion()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .digWorkAnnotationsObservable
            .sink { [unowned self] annotations in
                collection.clear()
                map.addAnnotations(annotations, cluster: collection)
            }
            .store(in: &cancellables)
    }
    
    private func configureModalSubscription(for modal: DigWorkBottomSheet, with annotations: [MKDigWorkAnnotation]) {
        modal.selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                let callout = DigWorkCallout()
                callout.configure(annotation: annotation)
                callout.showAlert(in: self)
            })
            .disposed(by: bag)
    }
    
}

extension DigWorkViewController {
    
    @objc func didTapFilterIcon() {
        let vc = DigWorkFilterBottomSheet()
        
        vc
            .selectedFilterObservable
            .subscribe(onNext: { [unowned self] filter in
                Task {
                    await viewModel.getDigWorkElements(filter: filter)
                }
            })
            .disposed(by: bag)
        
        vc
            .didDismissedObservable
            .subscribe(onNext: { [unowned self] in
                Task {
                    await viewModel.getDigWorkElements()
                }
            })
            .disposed(by: bag)
        present(vc, animated: true)
    }
    
}

extension DigWorkViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}

extension DigWorkViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
        cluster.addClusterTapListener(with: self)
    }
    
}

extension DigWorkViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKDigWorkAnnotation }
        
        annotations.forEach { print($0.coordinates) }
        annotations.forEach { print($0.title) }
        
        if viewModel.isClusterWithTheSameCoordinates(annotations: annotations) {
            let modal = DigWorkBottomSheet()
            configureModalSubscription(for: modal, with: annotations)
            modal.configureModal(annotations: annotations)
            present(modal, animated: true)
        }
        
        return true
    }
    
}

extension DigWorkViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKDigWorkAnnotation else { return false }
        
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}
