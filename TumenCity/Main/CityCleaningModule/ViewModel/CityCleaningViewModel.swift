//
//  CityCleaningViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit
import RxSwift
import RxRelay
import Alamofire
import Combine

@MainActor
final class CityCleaningViewModel {
    
    private var cityCleaningAnnotations = BehaviorRelay<[MKCityCleaningAnnotation]>(value: [])
    private var cityCleaningAnnotationsDefault = [MKCityCleaningAnnotation]()
    private var cityCleaningItems = [CityCleaningItemInfo]()
    private var isLoading = BehaviorRelay<Bool>(value: true)
    private var cancellables = Set<AnyCancellable>()
    
    var cityCleaningAnnotationsObservable: Observable<[MKCityCleaningAnnotation]> {
        cityCleaningAnnotations.asObservable()
    }
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getCityCleaningItems()
            print(cityCleaningItems)
        }
    }
    
    func filterAnnotationsByMachineType(type: Set<String>) {
        cityCleaningAnnotations.accept(cityCleaningAnnotationsDefault)
        let filterd = cityCleaningAnnotations.value.filter { type.contains($0.carType) }
        cityCleaningAnnotations.accept(filterd)
    }
    
    func filterAnnotationsByContractors(contractors: [String : Set<String>]) {
        let filtered = cityCleaningAnnotations.value.filter {
            if let contractorSet = contractors[$0.council] {
                return contractorSet.contains($0.contractor)
            }
            return false
        }
        cityCleaningAnnotations.accept(filtered)
    }
    
    func getCityCleaningItems() async {
        isLoading.accept(true)
        await APIManager().fetchDataWithParameters(type: CityCleaning.self,
                                                   endpoint: .cityCleaning)
        .publisher
        .sink { completion in
            self.isLoading.accept(false)
            if case let .failure(error) = completion {
                self.onError?(error)
            }
        } receiveValue: { cityCleaning in
            self.cityCleaningItems = cityCleaning.info
            self.createAnnotations()
        }
        .store(in: &cancellables)
    }
    
    private func getAnnotationTypeByIcon(_ icon: CityCleaningItemIcon) -> UIImage? {
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
        case .modulesGraderNewImgTypesType5SVG:
            return .init(named: "pin-5")
        case .modulesGraderNewImgTypesType6SVG:
            return .init(named: "pin-6")
        case .modulesGraderNewImgTypesType7SVG:
            return .init(named: "pin-7")
        case .modulesGraderNewImgTypesType8SVG:
            return .init(named: "pin-8")
        case .modulesGraderNewImgTypesType9SVG:
            return .init(named: "pin-9")
        case .modulesGraderNewImgTypesTypeSVG:
            return nil
        }
    }
    
    private func createAnnotations() {
        var annotations = [MKCityCleaningAnnotation]()
        
        cityCleaningItems.forEach { item in
            let lat = item.gps.first ?? 0
            let long = item.gps.last ?? 0
            let annotationIcon = getAnnotationTypeByIcon(item.icon) ?? .add
            
            let annotation = MKCityCleaningAnnotation(coordinates: .init(latitude: lat, longitude: long), contractor: item.contractor,
                                                      number: item.number, carType: item.type ?? "", icon: annotationIcon,
                                                      speed: item.speed, date: item.dtime, council: item.councilFormatted)
            
            annotations.append(annotation)
        }
        
        cityCleaningAnnotations.accept(annotations)
        cityCleaningAnnotationsDefault = annotations
    }
    
}
