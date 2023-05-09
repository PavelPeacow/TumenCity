//
//  DigWorkViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import YandexMapsMobile

class DigWorkViewController: UIViewController {

    private let viewModel = DigWorkViewModel()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var map: YMKMapView = {
        let map = YMKMapView()
        map.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        map.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 20, verticalPadding: 50*2))
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        map.setDefaultRegion()
        
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        
        setConstraints()
    }
    

}

extension DigWorkViewController: DigWorkViewModelDelegate {
    
    func didFinishAddingAnnotations(_ annotations: [MKDigWorkAnnotation]) {
        map.addAnnotations(annotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
}

extension DigWorkViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
    }
    
}

extension DigWorkViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKDigWorkAnnotation else { return false }
        
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension DigWorkViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
}
