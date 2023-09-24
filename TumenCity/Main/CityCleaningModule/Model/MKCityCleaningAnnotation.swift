//
//  MKCityCleaningAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import YandexMapsMobile
import MapKit

final class MKCityCleaningAnnotation: YMKPoint, YMKAnnotation {

    let coordinates: CLLocationCoordinate2D
    let contractor: String
    let number: String?
    let carType: String
    let icon: UIImage
    let speed: Int?
    let date: String
    let council: String
    let title: String
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    init(coordinates: CLLocationCoordinate2D, contractor: String, number: String?, carType: String,
         icon: UIImage, speed: Int?, date: String, council: String) {
        self.coordinates = coordinates
        self.contractor = contractor
        self.number = number
        self.title = number ?? ""
        self.carType = carType
        self.icon = icon
        self.speed = speed
        self.date = date
        self.council = council
    }
    
}
