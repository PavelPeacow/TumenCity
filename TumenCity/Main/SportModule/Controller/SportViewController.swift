//
//  SportViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import YandexMapsMobile

class SportViewController: UIViewControllerMapSegmented {
    
    private let sportRegistryView: SportRegistryView
    private let sportRegistrySearchResult: SportRegistrySearchViewController
    
    private var timer: Timer?
    
    private let viewModel = SportViewModel()
    
    private let map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    init(sportRegistryView: SportRegistryView, sportRegistrySearchResult: SportRegistrySearchViewController) {
        self.sportRegistryView = sportRegistryView
        self.sportRegistrySearchResult = sportRegistrySearchResult
        
        super.init(mainMapView: map, registryView: sportRegistryView, registrySearchResult: sportRegistrySearchResult)
        super.addItemsToSegmentControll(["Карта", "Реестр"])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Спорт"
        
        view.backgroundColor = .systemBackground
        
        viewModel.delegate = self
        sportRegistryView.delegate = self
        sportRegistrySearchResult.delegate = self
        
    }
    
    override func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        
        guard let searchText = searchController.searchBar.text else { return map.setDefaultRegion() }
        guard !searchText.isEmpty else { return map.setDefaultRegion() }
        
        if segmentedIndex == 1 {
            sportRegistrySearchResult.filterSearch(with: searchText)
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            if let annotation = self?.viewModel.searchAnnotationByName(searchText) {
                self?.map.moveCameraToAnnotation(annotation)
            } else {
                self?.map.setDefaultRegion()
            }
        })
    }
    
}

extension SportViewController: SportViewModelDelegate {
    
    func didFinishAddingAnnotations(_ annotations: [MKSportAnnotation]) {
        map.addAnnotations(annotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
        
        sportRegistryView.sportElements = viewModel.sportElements
        sportRegistrySearchResult.configure(sportElements: viewModel.sportElements)
        sportRegistryView.tableView.reloadData()
    }
    
}

extension SportViewController: SportRegistryViewDelegate {
    
    func didGetAddress(_ address: Address) {
        resetSegmentedControlAfterRegistryView()
        
        guard case .double(let lat) = address.latitude else { return }
        guard case .double(let long) = address.longitude else { return }
        
        map.moveCameraToAnnotation(latitude: lat, longitude: long)
    }
    
}

extension SportViewController: SportRegistrySearchViewControllerDelegate {
    
    func didTapSearchResult(_ result: SportElement) {
        resetSegmentedControlAfterRegistryView()
        
        if let annotation = viewModel.sportAnnotations.first(where: { $0.title == result.title }) {
            map.moveCameraToAnnotation(annotation)
        }
    }
    
}

extension SportViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKSportAnnotation else { return false }
        
        let callout = SportCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension SportViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
    }
    
}