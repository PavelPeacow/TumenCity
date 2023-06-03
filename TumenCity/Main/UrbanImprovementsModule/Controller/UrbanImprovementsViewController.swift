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
    
    var currentActiveFilterID: Int?
    
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
        bottomSheet.configure(filters: viewModel.filterItems, currentActiveFilterID: currentActiveFilterID)
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
        
        currentActiveFilterID = filterID
    }
    
    func didTapDiscardFilterBtn() {
        resetMap()
        
        let annotations = viewModel.urbanAnnotations
        let polygons = viewModel.polygonsFormatted
        
        map.addAnnotations(annotations, cluster: collection)
        
        polygons.forEach { polygon in
            map.addPolygon(polygon.0, polygonData: polygon.1, tapListener: self)
        }
        
        currentActiveFilterID = nil
    }
    
}

extension UrbanImprovementsViewController: UrbanImprovementsViewModelDelegate {
    
    func didFinishAddingMapObjects(_ pointsAnnotations: [MKUrbanAnnotation], _ polygons: [(YMKPolygon, UrbanPolygon)]) {
        map.addAnnotations(pointsAnnotations, cluster: collection)
        collection.addTapListener(with: self)
        
        polygons.forEach { polygon in
            map.addPolygon(polygon.0, polygonData: polygon.1, tapListener: self)
        }
    }
    
}

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
        guard viewModel.isClusterWithTheSameCoordinates(annotations: annotations) else { return false }
        
        let bottomSheet = UrbanImprovementsBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        present(bottomSheet, animated: true)
        
        return true
    }
    
}

extension UrbanImprovementsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let polygon = mapObject as? YMKPolygonMapObject {
            guard let polygonData = polygon.userData as? UrbanPolygon else { return false }
            
            print(polygonData.filterTypeID)
            return true
        }
        
        if let point = mapObject as? YMKPlacemarkMapObject {
            guard let annotation = point.userData as? MKUrbanAnnotation else { return false }
            print(annotation)
            
            Task {
                if let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(annotation.id) {
                    let callout = UrbanImprovementsCallout()
                    callout.configure(urbanDetailInfo: detailInfo)
                    callout.showAlert(in: self)
                    return true
                }
                return false
            }
           
        }
        
        return false
    }
    
}
