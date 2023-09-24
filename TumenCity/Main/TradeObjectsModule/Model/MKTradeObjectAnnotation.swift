//
//  MKTradeObjectAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import MapKit
import YandexMapsMobile

final class MKTradeObjectAnnotation: YMKPoint, YMKAnnotation {

    let coordinates: CLLocationCoordinate2D
    var icon: UIImage { type.image ?? .actions }
    let type: AnnotationType
    let id: String
    let address: String
    let title: String
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    init(id: String, address: String, coordinates: CLLocationCoordinate2D, tradeType: Bool) {
        self.id = id
        self.address = address
        self.title = address
        self.coordinates = coordinates
        self.type = tradeType ? .activeTrade : .freeTrade
    }
    
}

extension MKTradeObjectAnnotation {
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
}
