//
//  CloseRoadsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import UIKit
import YandexMapsMobile

class CloseRoadsViewController: UIViewController {
    
    let viewModel = CloseRoadsViewModel()
    
    lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var map: YMKMapView = {
        let map = YMKMapView()
        map.setDefaultRegion()
        map.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        map.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 20, verticalPadding: 50*2))
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(map)

        setDelegates()
        setConstraints()
    }
    
    func setDelegates() {
        viewModel.delegate = self
    }
    
}

extension CloseRoadsViewController: CloseRoadsViewModelDelegate {
    
    func didAddObjectToMap(roadAnnotations: [MKCloseRoadAnnotation], roadPolygons: [YMKPolygon]) {
        roadPolygons.forEach { polygon in
            let polygonMapObject = map.mapWindow.map.mapObjects.addPolygon(with: polygon)
            polygonMapObject.fillColor = UIColor.red.withAlphaComponent(0.16)
            polygonMapObject.strokeWidth = 3.0
            polygonMapObject.strokeColor = .red
        }
        
        map.addAnnotations(roadAnnotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    
}

extension CloseRoadsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCloseRoadAnnotation }
        cluster.appearance.setStaticImage(clusterAnnotations: annotations)
    }
    
}

extension CloseRoadsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCloseRoadAnnotation else { return false }
        
        let callout = CloseRoadCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension CloseRoadsViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
}
