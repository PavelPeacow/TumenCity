//
//  UrbanImprovementsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

protocol UrbanImprovementsActionsHandable: ViewActionBaseMapHandable {
    func handleOpenFilter()
    func handleAddPolygons(_ polygons: [(YMKPolygon, UrbanPolygon)])
    func handleShowPolygonCallout(_ polygon: UrbanPolygon)
}

final class UrbanImprovementsViewController: UIViewController {
    enum Actions {
        case openFilter
        case setLoading(isLoading: Bool)
        case showSnackbar(type: SnackBarView.SnackBarType)
        case addPolygons(polygons: [(YMKPolygon, UrbanPolygon)])
        case addAnnotations(annotations: [MKUrbanAnnotation])
        case tapCluster(annotations: [YMKAnnotation])
        case showCallout(annotation: MKUrbanAnnotation)
        case showPolygonCallout(polygon: UrbanPolygon)
    }
    
    // MARK: - Properties
    var actionsHandable: UrbanImprovementsActionsHandable?
    
    private let viewModel: UrbanImprovementsViewModel
    private let bag = DisposeBag()
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    private lazy var mapObjectsCollection = map.mapView.mapWindow.map.mapObjects.add()
    private var currentActiveFilterID: Int? = nil
    
    private lazy var map = YandexMapView()
    private lazy var loadingController = LoadingViewController()
    private lazy var loadingControllerForModal = LoadingViewController(type: .secondaryLoading)
    
    // MARK: - Init
    init(viewModel: UrbanImprovementsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpMap()
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getUrbanImprovements()
            }
        })
    }
    
    // MARK: - Setup
    private func setUpView() {
        title = L10n.UrbanImprovements.title
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterBtn))
    }
    
    private func setUpMap() {
        map.setYandexMapLayout(in: self.view)
        mapObjectsCollection.addTapListener(with: self)
        collection.addTapListener(with: self)
    }
    
    // MARK: - Bindings
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                action(.setLoading(isLoading: isLoading))
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .mapObjectsObservable
            .subscribe(onNext: { [unowned self] pointsAnnotations, polygons in
                resetMap()
                
                action(.addAnnotations(annotations: pointsAnnotations))
                action(.addPolygons(polygons: polygons))
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForUrbanImprovementsFilterBottomSheet(for modal: UrbanImprovementsFilterBottomSheet) {
        modal
            .selectedFilterObservable
            .subscribe(onNext: { [unowned self] selectedFilterIndex in
                resetMap()
                
                let filteredAnnotations = viewModel.filterAnnotationsByFilterID(selectedFilterIndex)
                let filteredPolygons = viewModel.filterPolygonsByFilterID(selectedFilterIndex)
                
                action(.addAnnotations(annotations: filteredAnnotations))
                action(.addPolygons(polygons: filteredPolygons))
                
                currentActiveFilterID = selectedFilterIndex
            })
            .disposed(by: bag)
        
        modal
            .didDiscardFilterObservable
            .subscribe(onNext: { [unowned self] in
                resetMap()
                
                let annotations = viewModel.urbanAnnotations
                let polygons = viewModel.polygonsFormatted
                
                action(.addAnnotations(annotations: annotations))
                action(.addPolygons(polygons: polygons))
                
                currentActiveFilterID = nil
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForUrbanImprovementsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKUrbanAnnotation else { return }
                action(.showCallout(annotation: annotation))
            })
            .disposed(by: bag)
    }
    
    // MARK: - Functions
    private func resetMap() {
        collection.clear()
        mapObjectsCollection.clear()
    }
}

// MARK: - Actions
extension UrbanImprovementsViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
        case .openFilter:
            actionsHandable?.handleOpenFilter()

        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)

        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)

        case .addPolygons(let polygons):
            actionsHandable?.handleAddPolygons(polygons)

        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)

        case .tapCluster(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)

        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)

        case .showPolygonCallout(let polygon):
            actionsHandable?.handleShowPolygonCallout(polygon)
        }
    }
}

// MARK: - Actions Handlers
extension UrbanImprovementsViewController: UrbanImprovementsActionsHandable {
    func handleOpenFilter() {
        let bottomSheet = UrbanImprovementsFilterBottomSheet()
        bottomSheet.configure(filters: viewModel.filterItems, currentActiveFilterID: currentActiveFilterID)
        setUpBindingsForUrbanImprovementsFilterBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
    
    func handleAddPolygons(_ polygons: [(YMKPolygon, UrbanPolygon)]) {
        polygons.forEach { polygon in
            map.mapView.addPolygon(polygon.0, polygonData: polygon.1, color: polygon.1.polygonColor.withAlphaComponent(0.5), collection: mapObjectsCollection)
        }
    }
    
    func handleShowPolygonCallout(_ polygon: UrbanPolygon) {
        Task {
            guard let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(polygon.id) else { return }

            let callout = UrbanImprovementsCallout()
            callout.configure(urbanDetailInfo: detailInfo, calloutImage: polygon.icon)
            callout.showAlert(in: self)
        }
    }
    
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKUrbanAnnotation else { return }
        Task {
            guard let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(annotation.id) else { return }

            let callout = UrbanImprovementsCallout()
            callout.configure(urbanDetailInfo: detailInfo, calloutImage: annotation.icon)
            callout.showAlert(in: self)
        }
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        let bottomSheet = ClusterItemsListBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        setUpBindingsForUrbanImprovementsBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingController.showLoadingViewControllerIn(self)
        } else {
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        if case .error = type {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        SnackBarView(type: type,andShowOn: view)
    }
}

// MARK: - Objs function
private extension UrbanImprovementsViewController {
    @objc func didTapFilterBtn() {
        action(.openFilter)
    }
}

// MARK: Map logic
extension UrbanImprovementsViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
        cluster.addClusterTapListener(with: self)
    }
}

extension UrbanImprovementsViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        guard isClusterWithTheSameCoordinates(annotations: annotations) else { return false }
        action(.tapCluster(annotations: annotations))
        return true
    }
}

extension UrbanImprovementsViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let polygon = mapObject as? YMKPolygonMapObject {
            guard let polygonData = polygon.userData as? UrbanPolygon else { return false }
            print(polygonData.filterTypeID)
            action(.showPolygonCallout(polygon: polygonData))
            return true
        }
        
        if let point = mapObject as? YMKPlacemarkMapObject {
            guard let annotation = point.userData as? MKUrbanAnnotation else { return false }
            print(annotation)
            action(.showCallout(annotation: annotation))
            return true
        }
        
        return false
    }
}
