//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import YandexMapsMobile

final class CommunalServicesViewController: UIViewControllerMapSegmented {
    
    private lazy var collection = serviceMap.map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private let viewModel = CommunalServicesViewModel()
    private var timer: Timer?
    
    private let serviceMap: CommunalServicesView
    private let serviceRegistry: RegistryView
    private let serviceSearch: RegistySearchResultViewController
    
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
        
        serviceMap.map.setDefaultRegion()
        addItemsToSegmentControll()
        view.backgroundColor = .systemBackground
        
        title = "Отключение ЖКУ"
        
        setDelegates()
    }
    
    override func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()

        guard let searchText = searchController.searchBar.text else { return serviceMap.map.setDefaultRegion() }
        guard !searchText.isEmpty else { return serviceMap.map.setDefaultRegion() }

        if segmentedIndex == 1 {
            serviceSearch.filterSearch(with: searchText)
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            if let annotation = self?.viewModel.findAnnotationByAddressName(searchText) {
                self?.serviceMap.map.moveCameraToAnnotation(annotation)
            } else {
                self?.serviceMap.map.setDefaultRegion()
            }
        })
    }
    
    
    private func setDelegates() {
        viewModel.delegate = self
        serviceRegistry.delegate = self
        serviceSearch.delegate = self
    }
    
    private func addServicesInfo() {
        guard let communalServices = viewModel.communalServices else { return }
        
        for serviceInfo in communalServices.info {
            let icon = UIImage(named: "filter-\(serviceInfo.id)") ?? .add
            let title = serviceInfo.title
            let count = String(serviceInfo.count)
            
            let serviceInfoView = ServiceInfoView(icon: icon, title: title, count: count, serviceType: serviceInfo.id)
            serviceInfoView.delegate = self
            
            serviceMap.servicesInfoStackView.addArrangedSubview(serviceInfoView)
        }
    }

    private func showSelectedMark(_ mark: MarkDescription) {
        viewModel.resetFilterCommunalServices()
        serviceMap.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
        
        resetSegmentedControlAfterRegistryView()
        
        if let annotation = viewModel.annotations.first(where: { $0.markDescription.address == mark.address } ) {
            serviceMap.map.moveCameraToAnnotation(annotation)
        }
    }
    
    func addItemsToSegmentControll() {
        super.addItemsToSegmentControll(["Карта", "Реестр"])
    }
    
}

//MARK: - RegistryViewDelegate

extension CommunalServicesViewController: RegistryViewDelegate {
    
    func didGetAddress(_ mark: MarkDescription) {
        serviceMap.infoTitle.isHidden = true
        showSelectedMark(mark)
    }
    
}

extension CommunalServicesViewController: RegistySearchResultViewControllerDelegate {
    
    func didTapResultAddress(_ mark: MarkDescription) {
        serviceMap.infoTitle.isHidden = true
        showSelectedMark(mark)
    }
    
}

//MARK: - ServiceInfoViewDelegate

extension CommunalServicesViewController: ServiceInfoViewDelegate {
    
    func didTapServiceInfoView(_ serviceType: Int, _ view: ServiceInfoView) {
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
    
}

//MARK: - ViewModelDelegate

extension CommunalServicesViewController: CommunalServicesViewModelDelegate {
    
    func didUpdateAnnotations(_ annotations: [MKItemAnnotation]) {
        collection.clear()

        serviceMap.map.addAnnotations(annotations, cluster: collection)
        serviceMap.map.setDefaultRegion()
    }
    
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation]) {
        serviceMap.map.mapWindow.map.mapObjects.addTapListener(with: self)
        serviceMap.map.addAnnotations(annotations, cluster: collection)
        
        addServicesInfo()
        serviceRegistry.cards = viewModel.communalServicesFormatted
        serviceRegistry.tableView.reloadData()
        
        serviceSearch.configure(communalServicesFormatted: viewModel.communalServicesFormatted)
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
