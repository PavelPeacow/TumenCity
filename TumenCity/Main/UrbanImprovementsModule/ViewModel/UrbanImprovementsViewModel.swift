//
//  UrbanImprovementsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import Foundation
import YandexMapsMobile

protocol UrbanImprovementsViewModelDelegate: AnyObject {
    func didFinishAddingMapObjects(_ pointsAnnotations: [MKUrbanAnnotation], _ polygons: [YMKPolygon])
}

@MainActor
final class UrbanImprovementsViewModel {
    
    var filters = [Filter]()
    
    var pointsFeature = [PointsFeature]()
    var polygonsFeature = [PolygonsFeature]()
    
    var pointsAnnotations = [MKUrbanAnnotation]()
    var polygonsFormatted = [YMKPolygon]()
    
    weak var delegate: UrbanImprovementsViewModelDelegate?
    
    init() {
        Task {
            await getUrbanImprovements()
            createPoints()
            createPolygons()
            delegate?.didFinishAddingMapObjects(pointsAnnotations, polygonsFormatted)
        }
    }
    
    func getUrbanImprovements() async {
        do {
            let result = try await APIManager().decodeMock(type: UrbanImprovements.self, forResourse: "urbanMock")
            filters = result.filter
            pointsFeature = result.geo.points.features
            polygonsFeature = result.geo.polygons.features
        } catch {
            print(error)
        }
        
    }
    
    func createPoints() {
        pointsFeature.forEach { point in
            var type: MKUrbanAnnotation.AnnotationType
            
            let lat = point.geometry.coordinates.first ?? 0
            let long = point.geometry.coordinates.last ?? 0
            
            switch point.options.preset {
                
            case .islandsBlueCircleDotIconWithCaption:
                type = .blue
            case .islandsGreenCircleDotIconWithCaption:
                type = .green
            case .islandsLightBlueCircleDotIconWithCaption:
                type = .cyan
            case .islandsNightCircleDotIconWithCaption:
                type = .blue
            case .islandsOrangeCircleDotIconWithCaption:
                type = .yellow
            case .islandsRedCircleDotIconWithCaption:
                type = .red
            case .islandsVioletCircleDotIconWithCaption:
                type = .purple
            }
            
            let annotation = MKUrbanAnnotation(id: point.id, coordinates: .init(latitude: lat, longitude: long), type: type)
            print(lat)
            print(long)
            pointsAnnotations.append(annotation)
        }
    }
    
    func createPolygons() {
        polygonsFeature.forEach { polygon in
            
            polygon.geometry.coordinates.forEach { doubleCoordinate in
                var points = [YMKPoint]()
                
                doubleCoordinate.forEach { coordinate in
                    let lat = coordinate.first ?? 0
                    let long = coordinate.last ?? 0
                    let point = YMKPoint(latitude: lat, longitude: long)
                    points.append(point)
                }
                
                let polygon = YMKPolygon(outerRing: .init(points: points), innerRings: [])
                polygonsFormatted.append(polygon)
            }
            
            
        }
    }
    
}
