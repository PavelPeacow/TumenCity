//
//  BikePathsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation
import YandexMapsMobile
import Alamofire
import Combine

@MainActor
final class BikePathsViewModel {
    typealias MapObjectsTypealias = (polygons: [YMKPolygon : YMKPoint], polilines: [YMKPolyline : UIColor])?
    
    private var objects = [Object]()
    private var lines = [Line]()
    
    private var bikePoligons = [YMKPolygon : YMKPoint]()
    private var bikePoliline = [YMKPolyline : UIColor]()
    var bikeInfoLegendItems = [BikePathInfoLegend]()
    
    @Published private var mapObjects = MapObjectsTypealias(nil)
    @Published private var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    
    var mapObjectsObservable: AnyPublisher<MapObjectsTypealias, Never> {
        $mapObjects.eraseToAnyPublisher()
    }
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            isLoading = true
            async let bikePublisher = getBikePathsElements()
            async let infoPublisher = getBikeInfoLegendItems()
        
            Publishers
                .CombineLatest(await bikePublisher, await infoPublisher)
                .sink(receiveCompletion: { [unowned self] completion in
                    isLoading = false
                    if case let .failure(error) = completion {
                        self.onError?(error)
                    }
                }) { paths, info in
                    self.objects = paths.row.object
                    self.lines = paths.row.line
                    self.bikeInfoLegendItems = info
                }
                .store(in: &cancellables)
            
            formatBikeLine()
            
            mapObjects = (bikePoligons, bikePoliline)
        }
    }
    
    func getBikePathsElements() async -> Result<BikePaths, AFError>.Publisher {
        await APIManager()
            .fetchDataWithParameters(type: BikePaths.self, endpoint: .bikePath)
            .publisher
    }
    
    func getBikeInfoLegendItems() async -> Result<[BikePathInfoLegend], AFError>.Publisher {
        await APIManager()
            .fetchDataWithParameters(type: [BikePathInfoLegend].self,  endpoint: .bikeLegend)
            .publisher
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
