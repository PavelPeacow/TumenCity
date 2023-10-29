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

protocol CloseRoadsActionsHandable: ViewActionBaseMapHandable {
    func handleAddPolygons(_ polygons: [YMKPolygon])
}

final class CloseRoadsViewController: UIViewController {
    enum Actions {
        case setLoading(isLoading: Bool)
        case showSnackbar(type: SnackBarView.SnackBarType)
        case addAnnotations(annotations: [YMKAnnotation])
        case addPolygons(polygons: [YMKPolygon])
        case showCallout(annotation: YMKAnnotation)
        case tapCluster(annotations: [MKCloseRoadAnnotation])
    }
        
    // MARK: - Properties
    var actionsHandable: CloseRoadsActionsHandable?
    
    private let viewModel: CloseRoadsViewModel
    
    private var cancellables = Set<AnyCancellable>()
    private var bag = DisposeBag()
    
    private lazy var collection = self.map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    private lazy var mapObjectsCollection = map.mapView.mapWindow.map.mapObjects.add()
    
    // MARK: - Views
    private lazy var map = YandexMapView()
    private lazy var loadingView = LoadingViewController()
    
    // MARK: - Init
    init(viewModel: CloseRoadsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
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
    
    // MARK: - Setup
    private func setUpView() {
        title = "Перекрытие дорог"
        view.backgroundColor = .systemBackground
        map.setYandexMapLayout(in: self.view)
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    // MARK: - Setup Bindings
    private func setUpBindings() {
        viewModel
            .isLoadingObserable
            .sink { [unowned self] in
                action(.setLoading(isLoading: $0))
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .roadObjectsObserable
            .sink { [unowned self] (annotations, polygons) in
                collection.clear()
                mapObjectsCollection.clear()
                
                action(.addAnnotations(annotations: annotations))
                action(.addPolygons(polygons: polygons))
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                action(.showCallout(annotation: annotation))
            })
            .disposed(by: bag)
    }
}

// MARK: - Actions
extension CloseRoadsViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .addPolygons(let polygons):
            actionsHandable?.handleAddPolygons(polygons)
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .tapCluster(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        }
    }
}

// MARK: - Actions handable
extension CloseRoadsViewController: CloseRoadsActionsHandable {
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingView.showLoadingViewControllerIn(self)
        } else {
            loadingView.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: self.view)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleAddPolygons(_ polygons: [YMKPolygon]) {
        polygons.forEach { polygon in
            self.map.mapView.addPolygon(polygon, color: .red.withAlphaComponent(0.15), collection: mapObjectsCollection)
        }
    }
    
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKCloseRoadAnnotation else { return }
        let callout = CloseRoadCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        let bottomSheet = ClusterItemsListBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        setUpBindingsForTradeObjectsBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
}

// MARK: - Map Logic
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
            action(.tapCluster(annotations: annotations))
            return true
        }
        return false
    }
}

extension CloseRoadsViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? YMKAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}
