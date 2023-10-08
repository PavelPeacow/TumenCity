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
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var searchTextfield: SearchTextField = {
        SearchTextField()
    }()
    
    private lazy var suggestionTableView: SuggestionTableView = {
        SuggestionTableView()
    }()
    
    private lazy var loadingViewController = LoadingViewController()
    
    private lazy var map = YandexMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigationBar()
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getDigWorkElements()
            }
        })
    }
    
    private func setUpView() {
        title = L10n.DigWork.title
        view.backgroundColor = .systemBackground
        
        view.addSubview(suggestionTableView)
        view.addSubview(searchTextfield)
        
        map.setYandexMapLayout(in: self.view) {
            $0.top.equalTo(self.searchTextfield.snp.bottom).offset(5)
        }
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
        
        searchTextfield.setupTextfieldLayoutIn(view: view)
        suggestionTableView.setupSuggestionTableViewInView(view, topConstraint: {
            $0.top.equalTo(searchTextfield.snp.bottom)
        })
    }
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapFilterIcon))
    }
    
    private func bindSearchController() {
        searchTextfield
            .textPublisher
            .sink { [unowned self] str in
                guard str.count > 0 else {
                    suggestionTableView.hideTableSuggestions()
                    return
                }
                viewModel.searchQuery = str
                suggestionTableView.showTableSuggestions()
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindings() {
        bindSearchController()
        
        viewModel
            .isLoadingObservable
            .sink { [unowned self] in
                if $0 {
                    loadingViewController.showLoadingViewControllerIn(self)
                } else {
                    loadingViewController.removeLoadingViewControllerIn(self)
                }
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel.onEmptyResult = { [weak self] in
            guard let self else { return }
            SnackBarView(type: .warning(L10n.SnackBar.warning),
                         andShowOn: self.view)
        }
        
        viewModel
            .searchQueryObservable
            .sink { [unowned self] query in
                suggestionTableView.search(text: query)
                let annotation = viewModel.findAnnotationByAddressName(query)
                if let annotation {
                    map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    map.mapView.setDefaultRegion()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .digWorkAnnotationsObservable
            .sink { [unowned self] annotations in
                collection.clear()
                map.mapView.addAnnotations(annotations, cluster: collection)
                suggestionTableView.configure(suggestions: annotations.map { $0.address })
            }
            .store(in: &cancellables)
        
        suggestionTableView
            .selectedSuggestionObservable
            .subscribe(onNext: { [unowned self] text in
                searchTextfield.resetTextfieldState()
                let annotation = viewModel.findAnnotationByAddressName(text)
                if let annotation{
                    map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    map.mapView.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        searchTextfield
            .didClearTextPublisher
            .sink { [unowned self] in
                suggestionTableView.hideTableSuggestions()
            }
            .store(in: &cancellables)
    }
    
    private func configureModalSubscription(for modal: ClusterItemsListBottomSheet, with annotations: [MKDigWorkAnnotation]) {
        modal.selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKDigWorkAnnotation else { return }
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

extension DigWorkViewController: YMKClusterListener {

    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
        cluster.addClusterTapListener(with: self)
    }
    
}

extension DigWorkViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKDigWorkAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            let modal = ClusterItemsListBottomSheet()
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
