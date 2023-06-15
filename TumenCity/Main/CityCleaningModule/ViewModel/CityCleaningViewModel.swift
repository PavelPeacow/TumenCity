//
//  CityCleaningViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import Foundation

protocol CityCleaningViewModelDelegate: AnyObject {
    func didFinishAddingMapObjects(_ annotations: [MKCityCleaningAnnotation])
}

@MainActor
final class CityCleaningViewModel {
    
    var cityCleaningAnnotations = [MKCityCleaningAnnotation]()
    var cityCleaningItems = [CityCleaningItemInfo]()
    
    weak var delegate: CityCleaningViewModelDelegate?
    
    init() {
        Task {
            await getCityCleaningItems()
            createAnnotations()
            delegate?.didFinishAddingMapObjects(cityCleaningAnnotations)
            print(cityCleaningItems)
        }
    }
    
    func getCityCleaningItems() async {
        do {
            let result = try await APIManager().decodeMock(type: CityCleaning.self, forResourse: "cityCleaningMock")
            cityCleaningItems = result.info
        } catch {
            print(error)
        }
    }
    
    func getAnnotationTypeByIcon(_ icon: CityCleaningItemIcon) -> MKCityCleaningAnnotation.AnnotationType {
        switch icon {
        case .modulesGraderNewImgTypesType11SVG:
            return .icon11
        case .modulesGraderNewImgTypesType12SVG:
            return .icon12
        case .modulesGraderNewImgTypesType1SVG:
            return .icon1
        case .modulesGraderNewImgTypesType2SVG:
            return .icon2
        case .modulesGraderNewImgTypesType3SVG:
            return .icon3
        case .modulesGraderNewImgTypesType4SVG:
            return .icon4
        case .modulesGraderNewImgTypesType6SVG:
            return .icon6
        case .modulesGraderNewImgTypesType8SVG:
            return .icon8
        }
    }
    
    func createAnnotations() {
        var annotations = [MKCityCleaningAnnotation]()
        
        cityCleaningItems.forEach { item in
            let lat = item.gps.first ?? 0
            let long = item.gps.last ?? 0
            let annotationType = getAnnotationTypeByIcon(item.icon)
            
            let annotation = MKCityCleaningAnnotation(coordinates: .init(latitude: lat, longitude: long), contractor: item.contractor,
                                                      number: item.number, carType: item.type, type: annotationType,
                                                      speed: item.speed, date: item.dtime, council: item.council)
            
            annotations.append(annotation)
        }
        
        cityCleaningAnnotations = annotations
    }
    
}
