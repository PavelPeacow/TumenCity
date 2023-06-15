//
//  MKCityCleaningAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import YandexMapsMobile
import MapKit

final class MKCityCleaningAnnotation: YMKPoint {
    
    enum AnnotationType {
        case icon1
        case icon2
        case icon3
        case icon4
        case icon6
        case icon8
        case icon11
        case icon12
        
        var image: UIImage? {
            switch self {
                
            case .icon1:
                return .init(named: "pin-1")
            case .icon2:
                return .init(named: "pin-2")
            case .icon3:
                return .init(named: "pin-3")
            case .icon4:
                return .init(named: "pin-4")
            case .icon6:
                return .init(named: "pin-6")
            case .icon8:
                return .init(named: "pin-8")
            case .icon11:
                return .init(named: "pin-11")
            case .icon12:
                return .init(named: "pin-12")
            }
        }
    }
    
    var coordinates: CLLocationCoordinate2D
    var contractor: String
    var number: String?
    var carType: String
    var type: AnnotationType
    var icon: UIImage? { type.image }
    var speed: Int?
    var date: String
    var council: String
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    init(coordinates: CLLocationCoordinate2D, contractor: String, number: String?, carType: String,
         type: AnnotationType, speed: Int?, date: String, council: String) {
        self.coordinates = coordinates
        self.contractor = contractor
        self.number = number
        self.carType = carType
        self.type = type
        self.speed = speed
        self.date = date
        self.council = council
    }
    
}
