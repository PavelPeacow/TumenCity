//
//  CloseRoadsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import Foundation
import YandexMapsMobile
import MapKit
import Combine
import Alamofire

@MainActor
final class CloseRoadsViewModel {
    
    private var closeRoads = PassthroughSubject<[RoadCloseObject], Never>()
    private var roadPolygons = PassthroughSubject<[YMKPolygon], Never>()
    private var roadAnnotations = PassthroughSubject<[MKCloseRoadAnnotation], Never>()
    
    @Published var isLoading = true
    
    private var cancellables = Set<AnyCancellable>()
    
    var closeRoadsObserable: AnyPublisher<[RoadCloseObject], Never> {
        closeRoads.eraseToAnyPublisher()
    }
    var roadPolygonsObserable: AnyPublisher<[YMKPolygon], Never> {
        roadPolygons.eraseToAnyPublisher()
    }
    var roadAnnotationsObserable: AnyPublisher<[MKCloseRoadAnnotation], Never> {
        roadAnnotations.eraseToAnyPublisher()
    }
    var isLoadingObserable: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getCloseRoads()
        }
    }
    
    func getCloseRoads() async {
        isLoading = true
        await APIManager().fetchDataWithParameters(type: RoadCloseResponse.self,
                                                   endpoint: .closeRoads)
        .publisher
        .sink { completion in
            self.isLoading = false
            if case let .failure(error) = completion {
                self.onError?(error)
            }
        } receiveValue: { roadClose in
            self.closeRoads.send(roadClose.objects)
        }
        .store(in: &cancellables)
    }
    
    private func getImageForRoad(by intEnum: RoadCloseIcon) -> UIImage? {
        switch intEnum {
        case .close:
            return .init(named: "close")
        case .work:
            return .init(named: "work")
        case .noSign:
            return .init()
        }
    }
    
    func createCloseRoadAnnotation(objects: [RoadCloseObject]) {
        var annotations = [MKCloseRoadAnnotation]()
        var polygons = [YMKPolygon]()
        
        objects.forEach { object in
            let geoCoordinates = object.geomJSON.coordinates
            
            if case .double(let pointArray) = geoCoordinates {
                let lat = pointArray.last ?? 0
                let long = pointArray.first ?? 0
                let icon = getImageForRoad(by: object.sign) ?? .actions
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKCloseRoadAnnotation(title: object.name, itemDescription: object.comment,
                                                       dateStart: object.start, dateEnd: object.end,
                                                       coordinates: coordinate, color: .red, icon: icon)
                annotations.append(annotation)
            }
            
            if case .doubleArrayArray(let polygonArray) = geoCoordinates {
                var points = [YMKPoint]()
                
                polygonArray.forEach { collection in
                    
                    collection.forEach {  pointCoordinate in
                        let lat = pointCoordinate.last ?? 0
                        let long = pointCoordinate.first ?? 0
                        let point = YMKPoint(latitude: lat, longitude: long)
                        points.append(point)
                    }
                    
                    let polygon = YMKPolygon(outerRing: .init(points: points), innerRings: [])
                    polygons.append(polygon)
                }
            }
        }
        
        roadAnnotations.send(annotations)
        
        roadPolygons.send(polygons)
    }
}
