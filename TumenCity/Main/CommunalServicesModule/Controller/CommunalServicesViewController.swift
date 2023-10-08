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

final class CommunalServicesViewController: UIViewControllerMapSegmented {
    
    private lazy var collection = serviceMap.map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private let viewModel = CommunalServicesViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let serviceMap: CommunalServicesView
    private let serviceRegistry: RegistryView
    private let serviceSearch: RegistySearchResultViewController
    
    private lazy var loadingController = LoadingViewController()
    
    init(serviceMap: CommunalServicesView, serviceRegistry: RegistryView, serviceSearch: RegistySearchResultViewController) {
        self.serviceMap = serviceMap
        self.serviceRegistry = serviceRegistry
        self.serviceSearch = serviceSearch
        super.init(mainMapView: serviceMap, registryView: serviceRegistry, registrySearchResult: serviceSearch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        addItemsToSegmentControll()
        view.backgroundColor = .systemBackground
        title = "Отключение ЖКУ"
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getCommunalServices()
            }
        })
        
        serviceRegistry
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] address in
                serviceMap.infoTitle.isHidden = true
                resetSegmentedControlAfterRegistryView()
                let annotation = viewModel.findAnnotationByAddressName(address.address)
                if let annotation {
                    serviceMap.map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.mapView.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        serviceSearch
            .selectedAddressesElementObservable
            .subscribe(onNext: { [unowned self] address in
                serviceMap.infoTitle.isHidden = true
                resetSegmentedControlAfterRegistryView()
                let annotation = viewModel.findAnnotationByAddressName(address.address)
                if let annotation {
                    serviceMap.map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.mapView.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        didEnterText
            .removeDuplicates()
            .sink { [unowned self] str in
                print(str)
                viewModel.searchQuery.onNext(str)
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    loadingController.showLoadingViewControllerIn(self)
                } else {
                    loadingController.removeLoadingViewControllerIn(self)
                }
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
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
                if let annotation {
                    serviceMap.map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.mapView.setDefaultRegion()
                }
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
                
                serviceMap.map.mapView.addAnnotations(annotations, cluster: collection)
                serviceMap.map.mapView.setDefaultRegion()
                // Filter for registry
                serviceRegistry.cards = communalServicesFormatted
                serviceRegistry.tableView.reloadData()
                serviceSearch.configure(communalServicesFormatted: communalServicesFormatted)
            })
            .disposed(by: bag)
        
        didSelectSuggestion = { [unowned self] text in
            let annotation = viewModel.findAnnotationByAddressName(text)
            if let annotation {
                serviceMap.map.mapView.moveCameraToAnnotation(annotation)
            } else {
                serviceMap.map.mapView.setDefaultRegion()
            }
        }
    }
    
    private func addBingingForService(_ service: ServiceInfoView) {
        service
            .tappedServiceInfoObservable
            .subscribe(onNext: { [unowned self] serviceType, view in
                checkTappedService(serviceType: serviceType, view: view)
            })
            .disposed(by: bag)
    }
    
    private func checkTappedService(serviceType: Int, view: ServiceInfoView) {
        guard !view.isTapAlready else {
            serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
            viewModel.resetFilterCommunalServices()
            
            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.serviceMap.infoTitle.isHidden = true
            }
            return
        }
        
        serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
        
        viewModel.filterCommunalServices(with: serviceType)
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.serviceMap.infoTitle.isHidden = false
            self?.serviceMap.infoTitle.text = view.serviceTitle
            self?.serviceMap.servicesInfoStackViewWithTitle.layoutIfNeeded()
        }
        
        view.isTapAlready = true
    }
    
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

//MARK: - MapDelegate

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
        
        let callout = CommunalServiceCallout()
        callout.configure(annotations: [annotation])
        callout.showAlert(in: self)
        return true
    }
}

extension CommunalServicesViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKItemAnnotation }
        
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            let callout = CommunalServiceCallout()
            callout.configure(annotations: annotations)
            callout.showAlert(in: self)
            return true
        }
        
        return false
    }
    
}
