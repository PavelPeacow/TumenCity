//
//  YandexMK+AddAnnotations.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func addAnnotations(_ annotations: [MKItemAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.image ?? .add)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
    func addAnnotations(_ annotations: [MKCloseRoadAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.icon ?? .add)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
    func addAnnotations(_ annotations: [MKSportAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.icon)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
    func addAnnotations(_ annotations: [MKDigWorkAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.icon)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
    func addAnnotations(_ annotations: [MKTradeObjectAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
        annotations.forEach { annotation in
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.image ?? .add)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 25)
    }
    
}
