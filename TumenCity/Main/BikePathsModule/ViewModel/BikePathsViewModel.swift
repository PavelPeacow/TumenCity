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
import Alamofire

@MainActor
final class BikePathsViewModel {
    typealias MapObjectsTypealias = (polygons: [YMKPolygon : YMKPoint], polilines: [YMKPolyline : UIColor])
    
    private var objects = [Object]()
    private var lines = [Line]()
    
    private var bikePoligons = [YMKPolygon : YMKPoint]()
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
    
    var onError: ((AFError) -> ())?
    
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
        let result = await APIManager().fetchDataWithParameters(type: BikePaths.self,
                                                                    endpoint: .bikePath)
        switch result {
        case .success(let success):
            objects = success.row.object
            lines = success.row.line
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
    }
    
    func getBikeInfoLegendItems() async {
        let result = await APIManager().fetchDataWithParameters(type: [BikePathInfoLegend].self,
                                                                    endpoint: .bikeLegend)
        switch result {
        case .success(let success):
            bikeInfoLegendItems = success
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
    }
    
    private func getMiddleCoordinate(from coordinates: [[Double]]) -> (lat: Double, long: Double) {
        guard !coordinates.isEmpty else {
            return (0,0)
        }
        
        let minLatitude = coordinates.min(by: { $0[0] < $1[0] })![0]
        let maxLatitude = coordinates.min(by: { $0[0] > $1[0] })![0]
        let minLongitude = coordinates.min(by: { $0[1] < $1[1] })![1]
        let maxLongitude = coordinates.min(by: { $0[1] > $1[1] })![1]

        let middleLatitude = (minLatitude + maxLatitude) / 2.0
        let middleLongitude = (minLongitude + maxLongitude) / 2.0

        return (middleLatitude, middleLongitude)
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
            
            let coordinates = points.reduce(into: [[Double]]()) { partialResult, point in
                let lat = point.latitude
                let long = point.longitude
                partialResult.append([lat, long])
            }
            
            let middlePoint = getMiddleCoordinate(from: coordinates)
            
            let middleMapPoint = YMKPoint(latitude: middlePoint.lat, longitude: middlePoint.long)
            
            let mapPolygon = YMKPolygon(outerRing: .init(points: points), innerRings: [])
            bikePoligons[mapPolygon] = middleMapPoint
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
