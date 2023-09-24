//
//  CloseRoadsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import UIKit
import YandexMapsMobile
import Combine
import RxSwift

final class CloseRoadsViewController: UIViewController {
    
    private let viewModel = CloseRoadsViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    private var bag = DisposeBag()
    
    private lazy var collection = self.map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    private lazy var mapObjectsCollection = map.mapView.mapWindow.map.mapObjects.add()
    
    private lazy var map = YandexMapView()
    
    private lazy var loadingView = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getCloseRoads()
            }
        })
    }
    
    private func setUpView() {
        title = "Перекрытие дорог"
        view.backgroundColor = .systemBackground
        map.setYandexMapLayout(in: self.view)
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObserable
            .sink { [unowned self] in
                if $0 {
                    loadingView.showLoadingViewControllerIn(self)
                } else {
                    loadingView.removeLoadingViewControllerIn(self)
                }
                
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
        }
        
        viewModel
            .roadObjectsObserable
            .sink { [unowned self] (annotations, polygons) in
                collection.clear()
                mapObjectsCollection.clear()
                
                map.mapView.addAnnotations(annotations, cluster: self.collection)
                
                polygons.forEach { polygon in
                    self.map.mapView.addPolygon(polygon, color: .red.withAlphaComponent(0.15), collection: mapObjectsCollection)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKCloseRoadAnnotation else { return }
                let callout = CloseRoadCallout()
                callout.configure(annotation: annotation)
                callout.showAlert(in: self)
            })
            .disposed(by: bag)
    }
}

extension CloseRoadsViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .red)
        cluster.addClusterTapListener(with: self)
    }
}

extension CloseRoadsViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCloseRoadAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            let bottomSheet = ClusterItemsListBottomSheet()
            bottomSheet.configureModal(annotations: annotations)
            setUpBindingsForTradeObjectsBottomSheet(for: bottomSheet)
            present(bottomSheet, animated: true)
            return true
        }
        
        return false
    }
}

extension CloseRoadsViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCloseRoadAnnotation else { return false }
        
        let callout = CloseRoadCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
}
