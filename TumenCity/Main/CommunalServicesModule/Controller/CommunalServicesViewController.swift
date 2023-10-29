//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift
import Combine

protocol CommunalServicesActionsHandable: ViewActionBaseMapHandable, ViewActionMoveCameraToAnnotationHandable {
    func handleTapFilter(type: Int, fitlerView: ServiceInfoView)
}

final class CommunalServicesViewController: UIViewControllerMapSegmented {
    enum Actions {
        case tapFilter(type: Int, fitlerView: ServiceInfoView)
        case addAnnotations(annotations: [YMKAnnotation])
        case moveCameraToAnnotation(annotation: YMKAnnotation?)
        case showSnackbar(type: SnackBarView.SnackBarType)
        case setLoading(isLoading: Bool)
        case showCallout(annotation: YMKAnnotation)
        case tapCluster(annotations: [YMKAnnotation])
    }
    
    // MARK: - Properties
    var actionsHandable: CommunalServicesActionsHandable?
    
    private lazy var collection = serviceMap.map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private let viewModel = CommunalServicesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views
    private let serviceMap: CommunalServicesView
    private let serviceRegistry: RegistryView
    private let serviceSearch: RegistySearchResultViewController
    
    private lazy var loadingController = LoadingViewController()
    
    // MARK: - Init
    init(serviceMap: CommunalServicesView, serviceRegistry: RegistryView, serviceSearch: RegistySearchResultViewController) {
        self.serviceMap = serviceMap
        self.serviceRegistry = serviceRegistry
        self.serviceSearch = serviceSearch
        super.init(mainMapView: serviceMap, registryView: serviceRegistry, registrySearchResult: serviceSearch)
        
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
    }
    
    // MARK: - Setup
    private func setUpView() {
        addItemsToSegmentControll()
        view.backgroundColor = .systemBackground
        title = "Отключение ЖКУ"
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getCommunalServices()
            }
        })
    }
    
    // MARK: - Setup bindings
    private func setUpBindings() {
        // Registry bindings
        serviceRegistry
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] address in
                serviceMap.infoTitle.isHidden = true
                resetSegmentedControlAfterRegistryView()
                let annotation = viewModel.findAnnotationByAddressName(address.address)
                action(.moveCameraToAnnotation(annotation: annotation))
            })
            .disposed(by: bag)
        
        serviceSearch
            .selectedAddressesElementObservable
            .subscribe(onNext: { [unowned self] address in
                serviceMap.infoTitle.isHidden = true
                resetSegmentedControlAfterRegistryView()
                let annotation = viewModel.findAnnotationByAddressName(address.address)
                action(.moveCameraToAnnotation(annotation: annotation))
            })
            .disposed(by: bag)
        
        didEnterText
            .removeDuplicates()
            .sink { [unowned self] str in
                print(str)
                viewModel.searchQuery.onNext(str)
            }
            .store(in: &cancellables)
        
        // View bindings
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] in
                action(.setLoading(isLoading: $0))
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .communalAnnotationsObservable
            .subscribe(
                onNext: { [unowned self] annotations in
                    collection.clear()
                    serviceMap.map.mapView.addAnnotations(annotations, cluster: collection)
                    
                    addServicesInfo()
                    serviceRegistry.cards = viewModel.communalServicesFormatted
                    serviceRegistry.tableView.reloadData()
                    
                    serviceSearch.configure(communalServicesFormatted: viewModel.communalServicesFormatted)
                    configureSuggestions(annotations.map { $0.title })
                },
                onCompleted: { [unowned self] in
                    serviceMap.map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
                })
            .disposed(by: bag)
        
        viewModel
            .searchQuery
            .filter { [unowned self] _ in segmentedIndex == 0 }
            .subscribe(onNext: { [unowned self] query in
                let annotation = viewModel.findAnnotationByAddressName(query)
                action(.moveCameraToAnnotation(annotation: annotation))
            })
            .disposed(by: bag)
        
        viewModel
            .searchQuery
            .filter { [unowned self] _ in segmentedIndex == 1 }
            .subscribe(onNext: { [unowned self] query in
                serviceSearch.filterSearch(with: query)
            })
            .disposed(by: bag)
        
        viewModel
            .filteredAnnotationsObservable
            .skip(1)
            .subscribe(onNext: { [unowned self] (annotations, communalServicesFormatted) in
                collection.clear()
                
                action(.addAnnotations(annotations: annotations))
                serviceMap.map.mapView.setDefaultRegion()
                // Filter for registry
                serviceRegistry.cards = communalServicesFormatted
                serviceRegistry.tableView.reloadData()
                serviceSearch.configure(communalServicesFormatted: communalServicesFormatted)
            })
            .disposed(by: bag)
        
        didSelectSuggestion = { [unowned self] text in
            let annotation = viewModel.findAnnotationByAddressName(text)
            action(.moveCameraToAnnotation(annotation: annotation))
        }
    }
    
    private func addBingingForService(_ service: ServiceInfoView) {
        service
            .tappedServiceInfoObservable
            .subscribe(onNext: { [unowned self] serviceType, view in
                action(.tapFilter(type: serviceType, fitlerView: view))
            })
            .disposed(by: bag)
    }
    
    // MARK: - Functions
    private func addServicesInfo() {
        guard let communalServices = viewModel.communalServices else { return }
        
        for serviceInfo in communalServices.info {
            let icon = UIImage(named: "filter-\(serviceInfo.id)") ?? .add
            let title = serviceInfo.title
            let count = String(serviceInfo.count)
            
            let serviceInfoView = ServiceInfoView(icon: icon, title: title, count: count, serviceType: serviceInfo.id)
            addBingingForService(serviceInfoView)
            
            serviceMap.servicesInfoStackView.addArrangedSubview(serviceInfoView)
        }
    }
    
    private func addItemsToSegmentControll() {
        super.addItemsToSegmentControll([L10n.MapSegmentSwitcher.map, L10n.MapSegmentSwitcher.registry])
    }
}

//MARK: - Actions
extension CommunalServicesViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .tapCluster(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        case .moveCameraToAnnotation(let annotation):
            actionsHandable?.handleMoveToAnnotation(annotation: annotation)
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .tapFilter(let type, let fitlerView):
            actionsHandable?.handleTapFilter(type: type, fitlerView: fitlerView)
        }
    }
}

//MARK: - Actions handable
extension CommunalServicesViewController: CommunalServicesActionsHandable {
    func handleMoveToAnnotation(annotation: YMKAnnotation?) {
        if let annotation {
            serviceMap.map.mapView.moveCameraToAnnotation(annotation)
        } else {
            serviceMap.map.mapView.setDefaultRegion()
        }
    }
    
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKItemAnnotation else { return }
        let callout = CommunalServiceCallout()
        callout.configure(annotations: [annotation])
        callout.showAlert(in: self)
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        guard let annotations = annotations as? [MKItemAnnotation] else { return }
        let callout = CommunalServiceCallout()
        callout.configure(annotations: annotations)
        callout.showAlert(in: self)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        serviceMap.map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingController.showLoadingViewControllerIn(self)
        } else {
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: view)
    }
    
    func handleTapFilter(type: Int, fitlerView: ServiceInfoView) {
        guard !fitlerView.isTapAlready else {
            serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
            viewModel.resetFilterCommunalServices()
            
            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.serviceMap.infoTitle.isHidden = true
            }
            return
        }
        
        serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
        
        viewModel.filterCommunalServices(with: type)
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.serviceMap.infoTitle.isHidden = false
            self?.serviceMap.infoTitle.text = fitlerView.serviceTitle
            self?.serviceMap.servicesInfoStackViewWithTitle.layoutIfNeeded()
        }
        
        fitlerView.isTapAlready = true
    }
}

//MARK: - Map Logic
extension CommunalServicesViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKItemAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
        cluster.addClusterTapListener(with: self)
    }
}

extension CommunalServicesViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKItemAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}

extension CommunalServicesViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKItemAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            action(.tapCluster(annotations: annotations))
            return true
        }
        return false
    }
}
