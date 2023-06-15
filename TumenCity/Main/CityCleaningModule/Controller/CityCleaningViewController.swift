//
//  CityCleaningViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit
import YandexMapsMobile

class CityCleaningViewController: UIViewController {
    
    let viewModel = CityCleaningViewModel()

    lazy var map = YandexMapMaker.makeYandexMap()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(createToken())
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        viewModel.delegate = self
        YandexMapMaker.setYandexMapLayout(map: map, in: view)
    }
    


}

extension CityCleaningViewController: CityCleaningViewModelDelegate {
    
    func didFinishAddingMapObjects(_ annotations: [MKCityCleaningAnnotation]) {
        map.addAnnotations(annotations, cluster: collection)
        collection.addTapListener(with: self)
    }
    
}

extension CityCleaningViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCityCleaningAnnotation else { return false }
        let callout = CityCleaningCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension CityCleaningViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCityCleaningAnnotation }
        cluster.appearance.setStaticImage(inClusterItemsCount: UInt(annotations.count), color: .orange)
    }
    
}
