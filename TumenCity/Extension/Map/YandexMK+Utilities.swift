//
//  YandexMK+Utilities.swift.swift
//  TumenCity
//
//  Created by Павел Кай on 20.02.2023.
//

import YandexMapsMobile

extension YMKMapView {
    
    func setDefaultRegion() {
        let tumenLatitude = 57.148470
        let tumenLongitude = 65.549138
        
        let center = YMKPoint(latitude: tumenLatitude, longitude: tumenLongitude)
        let zoom = Float(10)
        let azimuth = Float(0)
        let tilt = Float(0)
        
        let cameraPosition = YMKCameraPosition(target: center, zoom: zoom, azimuth: azimuth, tilt: tilt)
        
        mapWindow.map.move(with: cameraPosition, animationType: .init(type: .smooth, duration: 0.35), cameraCallback: nil)
    }
    
    func moveCameraToAnnotation(_ annotation: YMKPoint) {
        let latitude = annotation.latitude
        let longitude = annotation.longitude
        
        let center = YMKPoint(latitude: latitude, longitude: longitude)
        let zoom = Float(18)
        let azimuth = Float(0)
        let tilt = Float(0)

        let cameraPosition = YMKCameraPosition(target: center, zoom: zoom, azimuth: azimuth, tilt: tilt)
        
        mapWindow.map.move(with: cameraPosition, animationType: .init(type: .smooth, duration: 0.35), cameraCallback: nil)
    }
    
    func moveCameraToAnnotation(latitude: Double, longitude: Double) {
        let latitude = latitude
        let longitude = longitude
        
        let center = YMKPoint(latitude: latitude, longitude: longitude)
        let zoom = Float(18)
        let azimuth = Float(0)
        let tilt = Float(0)

        let cameraPosition = YMKCameraPosition(target: center, zoom: zoom, azimuth: azimuth, tilt: tilt)
        
        mapWindow.map.move(with: cameraPosition, animationType: .init(type: .smooth, duration: 0.35), cameraCallback: nil)
    }
      
}
