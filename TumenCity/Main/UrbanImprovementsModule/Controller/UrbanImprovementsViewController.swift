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
    
    lazy var map = YandexMapMaker.makeYandexMap()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: view)
        
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = .init(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterBtn))
    }
    


}

extension UrbanImprovementsViewController {
    
    @objc func didTapFilterBtn() {
        let bottomSheet = UrbanImprovementsFilterBottomSheet()
        bottomSheet.configure(filters: viewModel.filterItems)
        bottomSheet.delegate = self
        present(bottomSheet, animated: true)
    }
    
}

extension UrbanImprovementsViewController: UrbanImprovementsFilterBottomSheetDelegate {
    
    func didSelectFilter(_ filterID: Int) {
        let filteredAnnotations = viewModel.filterAnnotationsByFilterID(filterID)
        
        collection.clear()
        map.addAnnotations(filteredAnnotations, cluster: collection)
    }
    
}

extension UrbanImprovementsViewController: UrbanImprovementsViewModelDelegate {
    
    func didFinishAddingMapObjects(_ pointsAnnotations: [MKUrbanAnnotation], _ polygons: [YMKPolygon]) {
        map.addAnnotations(pointsAnnotations, cluster: collection)
        
        polygons.forEach { polygon in
            let poly = map.mapWindow.map.mapObjects.addPolygon(with: polygon)
            poly.strokeWidth = 1
            poly.strokeColor = .red
        }
    }
    
}

extension UrbanImprovementsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
    }
    
}
