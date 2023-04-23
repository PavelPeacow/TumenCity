//
//  MapKit+FillAnnotations.swift
//  TumenCity
//
//  Created by Павел Кай on 20.02.2023.
//

import MapKit
import YandexMapsMobile

extension YMKMapView {
    
    func setDefaultRegion() {
        let latitude = 57.148470
        let longitude = 65.549138
        
        let center = YMKPoint(latitude: latitude, longitude: longitude)
        let zoom = Float(10)
        let azimuth = Float(0)
        let tilt = Float(0)
        
        mapWindow.map.move(with: YMKCameraPosition(target: center, zoom: zoom, azimuth: azimuth, tilt: tilt))
    }
    
    func addAnnotations(_ annotations: [MKItemAnnotation], cluster: YMKClusterizedPlacemarkCollection) {
//        let mapObjects = mapWindow.map.mapObjects
//        
        annotations.forEach { annotation in
//            let placemark = cluster.addPlacemark(with: annotation, image: annotation.image ?? .add)
            let placemark = cluster.addPlacemark(with: annotation, image: annotation.image ?? .add)
            placemark.userData = annotation
            
        }
        cluster.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)

//        let placemark = YMKPlacemarkMapObject()
//        placemark.geometry = point
//        
//        let iconName = "your_icon_name" // Replace with your custom icon name
//        placemark.setIconWith(UIImage(named: iconName)!) // Set the custom icon for the marker
//        
        
        
       
    }
    
}

extension MKMapView {
    
    func fitAllAnnotations() {
        guard !annotations.isEmpty else { return setDefaultRegion() }
        var zoomRect = MKMapRect.null;
        
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func setDefaultRegion() {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
}
