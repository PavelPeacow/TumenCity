//
//  YandexMK+AddAnnotations.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func addAnnotations<T: YMKPoint & YMKAnnotation>(_ annotations: [T], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.icon)
            placemark.userData = annotation
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
}
