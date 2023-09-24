//
//  YandexMK+AddPolygon.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func addPolygon(_ polygon: YMKPolygon, polygonData: Any? = nil,
                    color: UIColor, strokeColor: UIColor = .clear, stroreWidth: Float = 3,
                    collection: YMKMapObjectCollection) {
        let polygon = collection.addPolygon(with: polygon)
        polygon.fillColor = color
        polygon.strokeWidth = stroreWidth
        polygon.strokeColor = strokeColor
        polygon.userData = polygonData
    }
    
}
