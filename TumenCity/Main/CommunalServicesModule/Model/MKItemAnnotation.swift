//
//  MKItemAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit
import YandexMapsMobile

final class MKItemAnnotation: YMKPoint, YMKAnnotation {
    
    let coordinates: CLLocationCoordinate2D
    let workType: String
    let dateStart: String
    let dateFinish: String
    let orgTitle: String
    let markDescription: MarkDescription
    let icon: UIImage
    let color: UIColor
    let index: Int
    let markType: MarkType
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    init(coordinates: CLLocationCoordinate2D, workType: String, dateStart: String, dateFinish: String,
         orgTitle: String, markDescription: MarkDescription, markIcon: UIImage, markColor: UIColor, index: Int) {
        self.coordinates = coordinates
        self.workType = workType
        self.dateStart = dateStart
        self.dateFinish = dateFinish
        self.orgTitle = orgTitle
        self.markDescription = markDescription
        self.icon = markIcon
        self.color = markColor
        self.index = index
        self.markType = MarkType(rawValue: index) ?? .none
    }
    
}
