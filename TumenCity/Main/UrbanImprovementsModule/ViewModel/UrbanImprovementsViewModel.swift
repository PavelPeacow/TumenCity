//
//  UrbanImprovementsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import Foundation
import YandexMapsMobile
import RxSwift
import RxRelay
import Alamofire

@MainActor
final class UrbanImprovementsViewModel {
    typealias MapObjectsTypealias = (pointsAnnotations: [MKUrbanAnnotation], polygons: [(YMKPolygon, UrbanPolygon)])
    
    var filters = [Filter]()
    var filterItems = [UrbanFilter]()
    
    var pointsFeature = [PointsFeature]()
    var polygonsFeature = [PolygonsFeature]()
    
    var urbanAnnotations = [MKUrbanAnnotation]()
    var polygonsFormatted = [(YMKPolygon, UrbanPolygon)]()
    
    private let isLoading = BehaviorRelay<Bool>(value: true)
    private let mapObjects = PublishSubject<MapObjectsTypealias>()
    
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    var mapObjectsObservable: Observable<MapObjectsTypealias> {
        mapObjects.asObservable()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getUrbanImprovements()
            createPoints()
            createPolygons()
            formatFilter()

            mapObjects
                .onNext((urbanAnnotations, polygonsFormatted))
        }
    }
    
    func filterAnnotationsByFilterID(_ filterID: Int) -> [MKUrbanAnnotation] {
        urbanAnnotations.filter { $0.filterTypeID == filterID }
    }
    
    func filterPolygonsByFilterID(_ filterID: Int) -> [(YMKPolygon, UrbanPolygon)] {
        polygonsFormatted.filter { $0.1.filterTypeID == filterID }
    }
    
    func isClusterWithTheSameCoordinates(annotations: [MKUrbanAnnotation]) -> Bool {
        annotations.dropFirst().allSatisfy( { $0.coordinates.latitude == annotations.first?.coordinates.latitude } ) ||
        annotations.dropFirst().allSatisfy( { String(format: "%.4f", $0.coordinates.latitude) == String(format: "%.4f", annotations.first!.coordinates.latitude) } )
    }
    
    func getUrbanImprovements() async {
        isLoading.accept(true)
        let result = await APIManager().fetchDataWithParameters(type: UrbanImprovements.self,
                                                                endpoint: .urbanImprovements)
            .publisher
            .sink { completion in
                self.isLoading.accept(false)
                if case let .failure(error) = completion {
                    self.onError?(error)
                }
            } receiveValue: { urbanImprovements in
                self.filters = urbanImprovements.filter
                self.pointsFeature = urbanImprovements.geo.points.features
                self.polygonsFeature = urbanImprovements.geo.polygons.features
            }
    }
    
    func getUrbanImprovementsDetailInfoByID(_ id: Int) async -> UrbanImprovementsDetailInfo? {
        let result = await APIManager().fetchDataWithParameters(type: UrbanImprovementsDetailInfo.self,
                                                                    endpoint: .urbanImprovementsInfo(id: id))
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            print(failure)
            onError?(failure)
            return nil
        }
    }
    
    func formatFilter() {
        filters.first?.item.forEach { filter in
            let filterImage = getImageFilterById(filter.id) ?? .add
            
            let filterItem = UrbanFilter(image: filterImage, title: filter.item, filterID: filter.id)
            filterItems.append(filterItem)
        }
    }
    
    func getImageFilterById(_ id: Int) -> UIImage? {
        switch id {
            
        case 9:
            return .init(named: "purpleMark")
        case 10:
            return .init(named: "yellowMark")
        case 11:
            return .init(named: "blueMark")
        case 12:
            return .init(named: "greenMark")
        case 62:
            return .init(named: "blackMark")
        case 63:
            return .init(named: "cyanMark")
        case 15:
            return .init(named: "redMark")
        default:
            return nil
        }
    }
    
    func getColorById(_ id: Int) -> UIColor? {
        switch id {
            
        case 9:
            return UIColor(named: "purple")
        case 10:
            return UIColor(named: "yellow")
        case 11:
            return UIColor(named: "blue")
        case 12:
            return UIColor(named: "green")
        case 62:
            return UIColor(named: "black")
        case 63:
            return UIColor(named: "cyan")
        case 15:
            return UIColor(named: "red")
        default:
            return nil
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
                type = .black
            case .islandsOrangeCircleDotIconWithCaption:
                type = .yellow
            case .islandsRedCircleDotIconWithCaption:
                type = .red
            case .islandsVioletCircleDotIconWithCaption:
                type = .purple
            }
            
            let annotation = MKUrbanAnnotation(title: point.properties.title, id: point.id, filterTypeID: point.properties.id, coordinates: .init(latitude: lat, longitude: long), type: type)
            print(lat)
            print(long)
            urbanAnnotations.append(annotation)
        }
    }
    
    func createPolygons() {
        polygonsFeature.forEach { polygon in
            
            let filterID = polygon.properties.id
            let color = getColorById(filterID) ?? .clear
            let icon = getImageFilterById(filterID) ?? .actions
            
            polygon.geometry.coordinates.forEach { doubleCoordinate in
                var points = [YMKPoint]()
                
                doubleCoordinate.forEach { coordinate in
                    let lat = coordinate.first ?? 0
                    let long = coordinate.last ?? 0
                    let point = YMKPoint(latitude: lat, longitude: long)
                    points.append(point)
                }
                
                let polygonID = polygon.id
                let polygon = YMKPolygon(outerRing: .init(points: points), innerRings: [])
                let polygonModel = UrbanPolygon(filterTypeID: filterID, polygonColor: color, id: polygonID, icon: icon)
                polygonsFormatted.append((polygon, polygonModel))
            }
            
            
        }
    }
    
}
