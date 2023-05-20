//
//  MKTradeObjectAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import MapKit
import YandexMapsMobile

final class MKTradeObjectAnnotation: YMKPoint {
    
    enum AnnotationType {
        case activeTrade
        case freeTrade
        
        var image: UIImage? {
            switch self {
                
            case .activeTrade:
                return .init(named: "pin-active")
            case .freeTrade:
                return .init(named: "pin-free")
            }
        }
    }
    
    var coordinates: CLLocationCoordinate2D
    var image: UIImage? { type.image }
    var type: AnnotationType
    var id: String
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    init(id: String, coordinates: CLLocationCoordinate2D, tradeType: Bool) {
        self.id = id
        self.coordinates = coordinates
        self.type = tradeType ? .activeTrade : .freeTrade
    }
    
}
