//
//  MKCloseRoadAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import YandexMapsMobile
import MapKit

final class MKCloseRoadAnnotation: YMKPoint {
    
    enum AnnotaionType: Int {
        case close = 1
        case work = 2
        case none = 3
        
        var image: UIImage? {
            switch self {
                
            case .close:
                return .init(named: "close")
            case .work:
                return .init(named: "work")
            case .none:
                return .init()
            }
        }
    }
    
    var title: String
    var itemDescription: String
    var dateStart: String
    var dateEnd: String
    var coordinate: CLLocationCoordinate2D
    var color: UIColor
    var type: AnnotaionType
    var icon: UIImage? { type.image }
    
    override var longitude: Double {
        coordinate.longitude.magnitude
    }

    override var latitude: Double {
        coordinate.latitude.magnitude
    }
    
    init(title: String, itemDescription: String, dateStart: String, dateEnd: String, coordinate: CLLocationCoordinate2D, color: UIColor, type: AnnotaionType.RawValue) {
        self.title = title
        self.itemDescription = itemDescription
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.coordinate = coordinate
        self.color = color
        self.type = AnnotaionType(rawValue: type) ?? . none
    }
    
}
