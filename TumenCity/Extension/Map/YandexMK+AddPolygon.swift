//
//  YandexMK+AddPolygon.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func addPolygon(_ polygon: YMKPolygon, polygonData: UrbanPolygon, tapListener: YMKMapObjectTapListener) {
        let polygon = mapWindow.map.mapObjects.addPolygon(with: polygon)
        polygon.fillColor = polygonData.polygonColor.withAlphaComponent(0.5)
        polygon.strokeWidth = 1
        polygon.userData = polygonData
        polygon.addTapListener(with: tapListener)
    }
    
}
