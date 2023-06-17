//
//  CloseRoadsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import Foundation
import YandexMapsMobile
import MapKit

protocol CloseRoadsViewModelDelegate: AnyObject {
    func didAddObjectToMap(roadAnnotations: [MKCloseRoadAnnotation], roadPolygons: [YMKPolygon])
}

@MainActor
final class CloseRoadsViewModel {
    
    var closeRoads = [RoadCloseObject]()
    
    weak var delegate: CloseRoadsViewModelDelegate?
    
    var roadPolygons = [YMKPolygon]()
    var roadAnnotations = [MKCloseRoadAnnotation]()
    
    init() {
        Task {
            await getCloseRoads()
            addCloseRoadToMap()
            delegate?.didAddObjectToMap(roadAnnotations: roadAnnotations, roadPolygons: roadPolygons)
        }
    }
    
    func getCloseRoads() async {
        do {
            let result = try await APIManager().getAPIContent(type: RoadCloseResponse.self, endpoint: .closeRoads)
            closeRoads = result.objects
            print(result.objects)
        } catch {
            print(error)
        }
    }
    
    func getImageForRoad(by intEnum: RoadCloseIcon) -> UIImage? {
        switch intEnum {
        case .close:
            return .init(named: "close")
        case .work:
            return .init(named: "work")
        case .noSign:
            return .init()
        }
    }
    
    func addCloseRoadToMap() {
        closeRoads.forEach { object in
            let geoCoordinates = object.geomJSON.coordinates
            let icon = getImageForRoad(by: object.sign) ?? .actions
            
            if case .double(let pointArray) = geoCoordinates {
                let lat = pointArray.last ?? 0
                let long = pointArray.first ?? 0
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKCloseRoadAnnotation(title: object.name, itemDescription: object.comment,
                                                       dateStart: object.start, dateEnd: object.end,
                                                       coordinates: coordinate, color: .red, icon: icon)
                roadAnnotations.append(annotation)
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
                    roadPolygons.append(polygon)
                }
                
            }
        }
        
    }
    
}
