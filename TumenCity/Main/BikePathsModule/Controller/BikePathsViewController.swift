//
//  BikePathsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit

class BikePathsViewController: UIViewController {
    
    let viewModel = BikePathsViewModel()
    
    lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        
        view.addSubview(map)
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "info.square"), style: .done, target: self, action: #selector(didTapBikeStatInfo))
        
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
    }
    
}

extension BikePathsViewController {
    
    @objc func didTapBikeStatInfo() {
        let bikeLegendInfo = BikePathInfoBottomSheet()
        let bikeInfo = viewModel.bikeInfoLegendItems
        bikeLegendInfo.configure(bikeInfoItems: bikeInfo)
        present(bikeLegendInfo, animated: true)
    }
    
}

extension BikePathsViewController: BikePathsViewModelDelegate {
    
    func finishAddingMapObjects(_ polygons: [YMKPolygon], _ polilines: [YMKPolyline : UIColor]) {
        polygons.forEach { polygon in
            let polygonCreated = map.mapWindow.map.mapObjects.addPolygon(with: polygon)
            polygonCreated.strokeWidth = 1
            polygonCreated.strokeColor = .systemGray
            polygonCreated.fillColor = .clear
        }
        
        polilines.forEach { polyline in
            let polylineCreated = map.mapWindow.map.mapObjects.addPolyline(with: polyline.key)
            polylineCreated.strokeWidth = 2.5
            polylineCreated.setStrokeColorWith(polyline.value)
        }
    }
    
}
