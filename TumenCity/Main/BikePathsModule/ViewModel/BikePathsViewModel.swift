//
//  BikePathsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation
import YandexMapsMobile

protocol BikePathsViewModelDelegate: AnyObject {
    func finishAddingMapObjects(_ polygons: [YMKPolygon], _ polilines: [YMKPolyline : UIColor])
}

@MainActor
final class BikePathsViewModel {
    
    var objects = [Object]()
    var lines = [Line]()
    
    var bikePoligons = [YMKPolygon]()
    var bikePoliline = [YMKPolyline : UIColor]()
    
    var bikeInfoLegendItems = [BikePathInfoLegend]()
    
    weak var delegate: BikePathsViewModelDelegate?
    
    init() {
        Task {
            
            await getBikePathsElements()
            await getBikeInfoLegendItems()
            formatBikeLine()
            delegate?.finishAddingMapObjects(bikePoligons, bikePoliline)
        }
    }
    
    func getBikePathsElements() async {
        let result = await APIManager().decodeMock(type: BikePaths.self, forResourse: "bikePathMock")
        objects = result.row.object
        lines = result.row.line
    }
    
    func getBikeInfoLegendItems() async {
        let result = await APIManager().decodeMock(type: [BikePathInfoLegend].self, forResourse: "bikePathInfoLegend")
        bikeInfoLegendItems = result
    }
    
    func formatBikeLine() {
        objects.forEach { object in
            guard let strPoligonData = object.fields.poligon.data(using: .utf8) else { return }
            
            let array = try? JSONDecoder().decode([[[Double]]].self, from: strPoligonData)
            
            var points = [YMKPoint]()
            
            array?.forEach { collection in
                
                collection.forEach { point in
                    let lat = point.first ?? 0
                    let long = point.last ?? 0
                    let point = YMKPoint(latitude: lat, longitude: long)
                    points.append(point)
                }
            }
            
            let mapPolygon = YMKPolygon(outerRing: .init(points: points), innerRings: [])
            bikePoligons.append(mapPolygon)
        }
        
        lines.forEach { line in
            guard let strPolilineData = line.fields.polyline.data(using: .utf8) else { return }
            
            let array = try? JSONDecoder().decode([[Double]].self, from: strPolilineData)
            
            var points = [YMKPoint]()
            
            array?.forEach { point in
                let lat = point.first ?? 0
                let long = point.last ?? 0
                let point = YMKPoint(latitude: lat, longitude: long)
                points.append(point)
            }
            
            let mapPolyline = YMKPolyline(points: points)
            let colorID = String(line.fields.typeCollor?.id ?? 1)
            let color = UIColor(named: colorID) ?? .black
            bikePoliline[mapPolyline] = color
        }

        print(bikePoliline)
    }
    
}
