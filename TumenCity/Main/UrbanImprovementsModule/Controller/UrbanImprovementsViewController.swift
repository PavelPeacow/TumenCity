//
//  UrbanImprovementsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import UIKit
import YandexMapsMobile

class UrbanImprovementsViewController: UIViewController {

    let viewModel = UrbanImprovementsViewModel()
    
    var isFilterActive = false
    
    lazy var map = YandexMapMaker.makeYandexMap()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        title = "Благоустройство"
        
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: view)
        
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = .init(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterBtn))
    }
    
    private func resetMap() {
        map.mapWindow.map.mapObjects.clear()
        collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    }

}

extension UrbanImprovementsViewController {
    
    @objc func didTapFilterBtn() {
        let bottomSheet = UrbanImprovementsFilterBottomSheet()
        bottomSheet.configure(filters: viewModel.filterItems, isFilterActive: isFilterActive)
        bottomSheet.delegate = self
        present(bottomSheet, animated: true)
    }
    
}

extension UrbanImprovementsViewController: UrbanImprovementsFilterBottomSheetDelegate {
    
    func didSelectFilter(_ filterID: Int) {
        resetMap()
        
        let filteredAnnotations = viewModel.filterAnnotationsByFilterID(filterID)
        let filteredPolygons = viewModel.filterPolygonsByFilterID(filterID)
        
        map.addAnnotations(filteredAnnotations, cluster: collection)
        
        filteredPolygons.forEach { polygon in
            map.addPolygon(polygon.0, polygonData: polygon.1, tapListener: self)
        }
        
        isFilterActive = true
    }
    
    func didTapDiscardFilterBtn() {
        resetMap()
        
        let annotations = viewModel.urbanAnnotations
        let polygons = viewModel.polygonsFormatted
        
        map.addAnnotations(annotations, cluster: collection)
        
        polygons.forEach { polygon in
            map.addPolygon(polygon.0, polygonData: polygon.1, tapListener: self)
        }
        
        isFilterActive = false
    }
    
}

extension UrbanImprovementsViewController: UrbanImprovementsViewModelDelegate {
    
    func didFinishAddingMapObjects(_ pointsAnnotations: [MKUrbanAnnotation], _ polygons: [(YMKPolygon, UrbanPolygon)]) {
        map.addAnnotations(pointsAnnotations, cluster: collection)
        
        polygons.forEach { polygon in
            map.addPolygon(polygon.0, polygonData: polygon.1, tapListener: self)
        }
    }
    
}

extension UrbanImprovementsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
    }
    
}

extension UrbanImprovementsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let polygon = mapObject as? YMKPolygonMapObject {
            guard let polygonData = polygon.userData as? UrbanPolygon else { return false }
            print(polygonData.filterTypeID)
            return true
        }
        
        return false
    }
    
}
