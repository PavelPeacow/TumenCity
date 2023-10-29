//
//  SportViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import YandexMapsMobile
import Combine
import RxSwift

protocol SportActionsHandable: ViewActionBaseMapHandable, ViewActionMoveCameraToAnnotationHandable { }

final class SportViewController: UIViewControllerMapSegmented {
    enum Actions {
        case moveCameraToAnnotation(annotation: YMKAnnotation?)
        case showSnackbar(type: SnackBarView.SnackBarType)
        case tapCluster(annotations: [YMKAnnotation])
        case showCallout(annotation: YMKAnnotation)
        case setLoading(isLoading: Bool)
        case addAnnotations(annotations: [YMKAnnotation])
    }
    
    // MARK: - Properties
    var actionsHandable: SportActionsHandable?
    
    private let viewModel: SportViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    // MARK: - Views
    private let map = YandexMapView()
    private let sportRegistryView: SportRegistryView
    private let sportRegistrySearchResult: SportRegistrySearchViewController
    private lazy var loadingViewController = LoadingViewController()
    
    // MARK: - Init
    init(viewModel: SportViewModel, sportRegistryView: SportRegistryView, sportRegistrySearchResult: SportRegistrySearchViewController) {
        self.viewModel = viewModel
        self.sportRegistryView = sportRegistryView
        self.sportRegistrySearchResult = sportRegistrySearchResult
        
        super.init(mainMapView: map, registryView: sportRegistryView, registrySearchResult: sportRegistrySearchResult)
        super.addItemsToSegmentControll([L10n.MapSegmentSwitcher.map, L10n.MapSegmentSwitcher.registry])
        
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
                await self.viewModel.getSportElements()
            }
        })
    }
    
    // MARK: - Setup
    private func setUpView() {
        title = L10n.Sport.title
        view.backgroundColor = .systemBackground
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    // MARK: - Setup bindings
    private func setUpBindings() {
        sportRegistryView
            .selectedSportAddressObservable
            .subscribe(onNext: { [unowned self] address in
                resetSegmentedControlAfterRegistryView()
                
                guard case .double(let lat) = address.latitude else { return }
                guard case .double(let long) = address.longitude else { return }
                
                map.mapView.moveCameraToAnnotation(latitude: lat, longitude: long)
            })
            .disposed(by: bag)
        
        sportRegistrySearchResult
            .selectedSportElementObservable
            .sink { [unowned self] sportElement in
                resetSegmentedControlAfterRegistryView()
                let annotation = viewModel.searchAnnotationByName(sportElement.title)
                action(.moveCameraToAnnotation(annotation: annotation))
            }
            .store(in: &cancellables)
        
        didEnterText
            .removeDuplicates()
            .sink { [unowned self] str in
                print(str)
                viewModel.searchQuery = str
            }
            .store(in: &cancellables)
        
        viewModel
            .isLoadingObservable
            .sink { [unowned self] in
                action(.setLoading(isLoading: $0))
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .sportElementsObservable
            .sink { [unowned self] objects in
                collection.clear()
                viewModel.addSportAnnotations(objects: objects)
                sportRegistryView.sportElements = objects
                
                sportRegistrySearchResult.configure(sportElements: objects)
                sportRegistryView.tableView.reloadData()
                configureSuggestions(objects.map { $0.title })
            }
            .store(in: &cancellables)
        
        viewModel
            .sportAnnotationsObservable
            .sink { [unowned self] annotations in
                action(.addAnnotations(annotations: annotations))
            }
            .store(in: &cancellables)
        
        viewModel
            .$searchQuery
            .filter { [unowned self] _ in segmentedIndex == 0 }
            .sink { [unowned self] query in
                let annotation = viewModel.searchAnnotationByName(String(query))
                action(.moveCameraToAnnotation(annotation: annotation))
            }
            .store(in: &cancellables)
        
        viewModel
            .$searchQuery
            .filter { [unowned self] _ in segmentedIndex == 1 }
            .sink { [unowned self] query in
                sportRegistrySearchResult.filterSearch(with: query)
            }
            .store(in: &cancellables)
        
        didSelectSuggestion = { [unowned self] text in
            let annotation = viewModel.searchAnnotationByName(text)
            action(.moveCameraToAnnotation(annotation: annotation))
        }
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
extension SportViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .tapCluster(annotations: let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .moveCameraToAnnotation(annotation: let annotation):
            actionsHandable?.handleMoveToAnnotation(annotation: annotation)
        }
    }
}

// MARK: - Actions handable
extension SportViewController: SportActionsHandable {
    func handleMoveToAnnotation(annotation: YMKAnnotation?) {
        if let annotation {
            map.mapView.moveCameraToAnnotation(annotation)
        } else {
            map.mapView.setDefaultRegion()
        }
    }
    
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKSportAnnotation else { return }
        let callout = SportCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        let bottomSheet = ClusterItemsListBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        setUpBindingsForTradeObjectsBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingViewController.showLoadingViewControllerIn(self)
        } else {
            loadingViewController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: view)
    }
    
    
}

// MARK: - Map Logic
extension SportViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKSportAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}

extension SportViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
        cluster.addClusterTapListener(with: self)
    }
}

extension SportViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKSportAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            action(.tapCluster(annotations: annotations))
            return true
        }
        
        return false
    }
}
