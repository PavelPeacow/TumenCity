//
//  MKDigWorkAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import MapKit
import YandexMapsMobile

final class MKDigWorkAnnotation: YMKPoint, YMKAnnotation {
    
    var title: String
    var contentDescription: String
    var icon: UIImage
    var coordinates: CLLocationCoordinate2D
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    init(title: String, contentDescription: String, icon: UIImage, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.contentDescription = contentDescription
        self.icon = icon
        self.coordinates = coordinates
    }
    
}
