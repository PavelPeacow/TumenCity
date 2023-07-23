//
//  BikePathsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation
import YandexMapsMobile
import RxSwift
import RxRelay

@MainActor
final class BikePathsViewModel {
    typealias MapObjectsTypealias = (polygons: [YMKPolygon], polilines: [YMKPolyline : UIColor])
    
    private var objects = [Object]()
    private var lines = [Line]()
    
    private var bikePoligons = [YMKPolygon]()
    private var bikePoliline = [YMKPolyline : UIColor]()
    var bikeInfoLegendItems = [BikePathInfoLegend]()
    
    private let mapObjects = PublishSubject<MapObjectsTypealias>()
    private let isLoading = BehaviorRelay<Bool>(value: false)
    
    var mapObjectsObservable: Observable<MapObjectsTypealias> {
        mapObjects.asObservable()
    }
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            isLoading.accept(true)
            await getBikePathsElements()
            await getBikeInfoLegendItems()
            formatBikeLine()
            isLoading.accept(false)
            mapObjects
                .onNext((bikePoligons, bikePoliline))
        }
    }
    
    func getBikePathsElements() async {
        do {
            let result = try await APIManager().getAPIContent(type: BikePaths.self, endpoint: .bikePath)
            objects = result.row.object
            lines = result.row.line
        } catch {
            print(error)
        }
    }
    
    func getBikeInfoLegendItems() async {
        do {
            let result = try await APIManager().getAPIContent(type: [BikePathInfoLegend].self, endpoint: .bikeLegend)
            bikeInfoLegendItems = result
        } catch {
            print(error)
        }
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
