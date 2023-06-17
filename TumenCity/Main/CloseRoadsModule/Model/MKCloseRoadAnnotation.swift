//
//  MKCloseRoadAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import YandexMapsMobile
import MapKit

final class MKCloseRoadAnnotation: YMKPoint, YMKAnnotation {
    
    let title: String
    let itemDescription: String
    let dateStart: String
    let dateEnd: String
    let coordinates: CLLocationCoordinate2D
    let color: UIColor
    let icon: UIImage
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }

    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    init(title: String, itemDescription: String, dateStart: String, dateEnd: String, coordinates: CLLocationCoordinate2D, color: UIColor, icon: UIImage) {
        self.title = title
        self.itemDescription = itemDescription
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.coordinates = coordinates
        self.color = color
        self.icon = icon
    }
    
}
