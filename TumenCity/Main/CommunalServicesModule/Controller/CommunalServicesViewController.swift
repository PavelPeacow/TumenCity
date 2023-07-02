//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

final class CommunalServicesViewController: UIViewControllerMapSegmented {
    
    private lazy var collection = serviceMap.map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private let viewModel = CommunalServicesViewModel()
    private let bag = DisposeBag()
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

        serviceRegistry
            .selectedAddressObservable
            .flatMap { [unowned self] address in
                viewModel.resetFilterCommunalServices()
                serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
                resetSegmentedControlAfterRegistryView()
                
                return viewModel.findAnnotationByAddressName(address.address)
            }
            .subscribe(onNext: { [unowned self] annotation in
                serviceMap.infoTitle.isHidden = true
                if let annotation {
                    serviceMap.map.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        serviceSearch
            .selectedAddressesElementObservable
            .flatMap { [unowned self] address in
                resetSegmentedControlAfterRegistryView()
                return viewModel.findAnnotationByAddressName(address.address)
            }
            .subscribe(onNext: { [unowned self] annotation in
                serviceMap.infoTitle.isHidden = true
                if let annotation{
                    serviceMap.map.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        didChangeSearchController
            .subscribe(onNext: { [unowned self] _ in
                searchController.searchBar.rx.text.onCompleted()
                bindSearchController()
                print("che")
            })
            .disposed(by: bag)
    }
    
    private func bindSearchController() {
        searchController.searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] str in
                viewModel.searchQuery.onNext(str)
            })
            .disposed(by: bag)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    loadingController.showLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = true
                    }
                } else {
                    loadingController.removeLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = false
                    }
                }
            })
            .disposed(by: bag)
        
        viewModel
            .communalAnnotationsObservable
            .subscribe(
                onNext: { [unowned self] annotations in
                    serviceMap.map.addAnnotations(annotations, cluster: collection)
                    
                    addServicesInfo()
                    serviceRegistry.cards = viewModel.communalServicesFormatted
                    serviceRegistry.tableView.reloadData()
                    
                    serviceSearch.configure(communalServicesFormatted: viewModel.communalServicesFormatted)
                },
                onCompleted: { [unowned self] in
                    serviceMap.map.mapWindow.map.mapObjects.addTapListener(with: self)
                })
            .disposed(by: bag)
        
        viewModel
            .searchQuery
            .filter { [unowned self] _ in segmentedIndex == 0 }
            .flatMap { [unowned self] query in
                viewModel.findAnnotationByAddressName(query)
            }
            .subscribe(onNext: { [unowned self] annotation in
                if let annotation{
                    serviceMap.map.moveCameraToAnnotation(annotation)
                } else {
                    serviceMap.map.setDefaultRegion()
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
            .subscribe(onNext: { [unowned self] annotations in
                collection.clear()
                serviceMap.map.addAnnotations(annotations, cluster: collection)
                serviceMap.map.setDefaultRegion()
            })
            .disposed(by: bag)
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
        super.addItemsToSegmentControll(["Карта", "Реестр"])
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
        
        if viewModel.isClusterWithTheSameCoordinates(annotations: annotations) {
            let callout = CommunalServiceCallout()
            callout.configure(annotations: annotations)
            callout.showAlert(in: self)
            return true
        }
        
        return false
    }
    
}
