//
//  MKUrbanAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import YandexMapsMobile
import MapKit

final class MKUrbanAnnotation: YMKPoint {
    
    enum AnnotationType {
        case purple
        case yellow
        case blue
        case green
        case black
        case cyan
        case red
        
        var image: UIImage? {
            switch self {
                
            case .purple:
                return .init(named: "purpleMark")
            case .yellow:
                return .init(named: "yellowMark")
            case .blue:
                return .init(named: "blueMark")
            case .green:
                return .init(named: "greenMark")
            case .black:
                return .init(named: "blackMark")
            case .cyan:
                return .init(named: "cyanMark")
            case .red:
                return .init(named: "redMark")
            }
        }
    }
    
    var id: Int
    var coordinates: CLLocationCoordinate2D
    var icon: UIImage? { type.image }
    var type: AnnotationType
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    init(id: Int, coordinates: CLLocationCoordinate2D, type: AnnotationType) {
        self.id = id
        self.coordinates = coordinates
        self.type = type
    }
    
}
