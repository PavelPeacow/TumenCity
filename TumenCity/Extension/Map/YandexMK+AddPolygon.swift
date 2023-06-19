//
//  YandexMK+AddPolygon.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func addPolygon(_ polygon: YMKPolygon, polygonData: Any? = nil, color: UIColor,
                    stroreWidth: Float = 3, tapListener: YMKMapObjectTapListener? = nil) {
        let polygon = mapWindow.map.mapObjects.addPolygon(with: polygon)
        polygon.fillColor = color
        polygon.strokeWidth = stroreWidth
        polygon.userData = polygonData
        if let tapListener {
            polygon.addTapListener(with: tapListener)
        }
    }
    
}
