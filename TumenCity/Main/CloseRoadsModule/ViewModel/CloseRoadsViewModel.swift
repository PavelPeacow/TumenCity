//
//  CloseRoadsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import Foundation
import YandexMapsMobile
import MapKit
import RxSwift
import RxRelay
import Alamofire

@MainActor
final class CloseRoadsViewModel {
    
    private var closeRoads = PublishSubject<[RoadCloseObject]>()
    private var roadPolygons = PublishSubject<[YMKPolygon]>()
    private var roadAnnotations = PublishSubject<[MKCloseRoadAnnotation]>()
    
    private var isLoading = BehaviorRelay<Bool>(value: false)
    
    var closeRoadsObserable: Observable<[RoadCloseObject]> {
        closeRoads.asObservable()
    }
    var roadPolygonsObserable: Observable<[YMKPolygon]> {
        roadPolygons.asObservable()
    }
    var roadAnnotationsObserable: Observable<[MKCloseRoadAnnotation]> {
        roadAnnotations.asObservable()
    }
    
    var isLoadingObserable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            isLoading.accept(true)
            await getCloseRoads()
            isLoading.accept(false)
        }
    }
    
    private func getCloseRoads() async {
        let result = await APIManager().fetchDataWithParameters(type: RoadCloseResponse.self,
                                                                    endpoint: .closeRoads)
        switch result {
        case .success(let success):
            closeRoads
                .onNext(success.objects)
            closeRoads
                .onCompleted()
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
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
        
        roadAnnotations
            .onNext(annotations)
        roadAnnotations
            .onCompleted()
        
        roadPolygons
            .onNext(polygons)
        roadPolygons
            .onCompleted()
    }
}
