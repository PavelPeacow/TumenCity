//
//  CityCleaningViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit

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
    
    func getAnnotationTypeByIcon(_ icon: CityCleaningItemIcon) -> UIImage? {
        switch icon {
        case .modulesGraderNewImgTypesType11SVG:
            return .init(named: "pin-11")
        case .modulesGraderNewImgTypesType12SVG:
            return .init(named: "pin-2")
        case .modulesGraderNewImgTypesType1SVG:
            return .init(named: "pin-1")
        case .modulesGraderNewImgTypesType2SVG:
            return .init(named: "pin-2")
        case .modulesGraderNewImgTypesType3SVG:
            return .init(named: "pin-3")
        case .modulesGraderNewImgTypesType4SVG:
            return .init(named: "pin-4")
        case .modulesGraderNewImgTypesType6SVG:
            return .init(named: "pin-6")
        case .modulesGraderNewImgTypesType8SVG:
            return .init(named: "pin-8")
        }
    }
 
    func createAnnotations() {
        var annotations = [MKCityCleaningAnnotation]()
        
        cityCleaningItems.forEach { item in
            let lat = item.gps.first ?? 0
            let long = item.gps.last ?? 0
            let annotationIcon = getAnnotationTypeByIcon(item.icon) ?? .add
            
            let annotation = MKCityCleaningAnnotation(coordinates: .init(latitude: lat, longitude: long), contractor: item.contractor,
                                                      number: item.number, carType: item.type, icon: annotationIcon,
                                                      speed: item.speed, date: item.dtime, council: item.council)
            
            annotations.append(annotation)
        }
        
        cityCleaningAnnotations = annotations
    }
    
}
