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

final class DigWorkViewController: UIViewController {
    
    private let viewModel = DigWorkViewModel()
    private let bag = DisposeBag()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Введите адрес..."
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    private lazy var loadingView = LoadingView(frame: view.bounds)
    
    private lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpNavigationBar()
        setUpBindings()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
        view.addSubview(loadingView)
    }
    
    private func setUpNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapFilterIcon))
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.isLoadingSubject)
            .disposed(by: bag)
        
        viewModel
            .isLoadingObservable
            .debug()
            .observe(on: MainScheduler.instance)
            .flip()
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel
            .digWorkAnnotationsObservable
            .subscribe(
                onNext: { [unowned self] annotations in
                    map.addAnnotations(annotations, cluster: collection)
                },
                onCompleted: { [unowned self] in
                    self.map.mapWindow.map.mapObjects.addTapListener(with: self)
                })
            .disposed(by: bag)
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
