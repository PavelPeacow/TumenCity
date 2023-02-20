//
//  MKItemAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit

final class MKItemAnnotation: NSObject, MKAnnotation {
    
    enum MarkType: Int {
        case cold = 1
        case hot = 2
        case otop = 4
        case electro = 5
        case gaz = 6
        case none = 7
        
        var image: UIImage? {
            switch self {
                
            case .cold:
                return UIImage(named: "filter-1")
            case .hot:
                return UIImage(named: "filter-2")
            case .otop:
                return UIImage(named: "filter-4")
            case .electro:
                return UIImage(named: "filter-5")
            case .gaz:
                return UIImage(named: "filter-6")
            case .none:
                return UIImage(systemName: "circle.fill")
            }
        }
        
        var color: UIColor {
            switch self {
                
            case .cold:
                return .blue
            case .hot:
                return .red
            case .otop:
                return .green
            case .electro:
                return .orange
            case .gaz:
                return .cyan
            case .none:
                return .white
            }
        }
    }
 
    var coordinate: CLLocationCoordinate2D
    var workType: String
    var dateStart: String
    var dateFinish: String
    var orgTitle: String
    var markDescription: MarkDescription
    var markType: MarkType
    var image: UIImage? { return markType.image }
    var color: UIColor { return markType.color }
    var index: Int { return markType.rawValue }
    
    init(coordinate: CLLocationCoordinate2D, workType: String, dateStart: String, dateFinish: String, orgTitle: String, markDescription: MarkDescription, markType: MarkType.RawValue) {
        self.coordinate = coordinate
        self.workType = workType
        self.dateStart = dateStart
        self.dateFinish = dateFinish
        self.orgTitle = orgTitle
        self.markDescription = markDescription
        self.markType = MarkType(rawValue: markType) ?? .none
    }
    
}
