//
//  TradeObjectsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire

@MainActor
final class TradeObjectsViewModel {
    
    var currentVisibleTradeObjectsAnnotations = BehaviorSubject<[MKTradeObjectAnnotation]>(value: [])
    
    var tradeObjects = [TradeObjectsRow]()
    var tradeObjectsAnnotations = BehaviorSubject<[MKTradeObjectAnnotation]>(value: [])
    
    var tradeObjectsType = [TradeObjectTypeRow]()
    var tradeObjectsPeriod = [TradeObjectPeriodRow]()
    
    private var isLoading = BehaviorRelay(value: false)
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    var currentVisibleTradeObjectsAnnotationsObservable: Observable<[MKTradeObjectAnnotation]> {
        currentVisibleTradeObjectsAnnotations.asObservable()
    }
    
    var tradeObjectsAnnotationsObservable: Observable<[MKTradeObjectAnnotation]> {
        tradeObjectsAnnotations.asObservable()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            isLoading.accept(true)
            await getTradeObjects()
            await getTradeObjectsType()
            await getTradeObjectsPeriod()
            
            let annotations = addAnnotations(tradeObjects: tradeObjects)
            
            tradeObjectsAnnotations
                .onNext(annotations)
            
            tradeObjectsAnnotations
                .onCompleted()
            
            currentVisibleTradeObjectsAnnotations
                .onNext(annotations)
            isLoading.accept(false)
        }
    }
    
    func getDefualtTradeAnnotations() -> [MKTradeObjectAnnotation] {
        guard let values = try? tradeObjectsAnnotations.value() else { return [] }
        return values
    }
    
    func getCurrentVisibleTradeAnnotations() -> [MKTradeObjectAnnotation] {
        guard let values = try? currentVisibleTradeObjectsAnnotations.value() else { return [] }
        return values
    }
    
    func filterAnnotationsByType(_ type: MKTradeObjectAnnotation.AnnotationType) -> [MKTradeObjectAnnotation] {
        guard let annotations = try? currentVisibleTradeObjectsAnnotations.value() else {
            return []
        }
        return annotations.filter { $0.type == type }
    }
    
    func isClusterWithTheSameCoordinates(annotations: [MKTradeObjectAnnotation]) -> Bool {
        return annotations.dropFirst().allSatisfy( { $0.coordinates.latitude == annotations.first?.coordinates.latitude } )
    }
    
    func isTradeObjectDateGreaterThanToday(_ strDate: String?, numberDocument: String?) -> Bool {
        guard let strDate, let _ = numberDocument else { return false }
        
        let date = DateFormatter()
        date.dateFormat = "dd-MM-yyyy"
        
        guard let tradeObjectDate = date.date(from: strDate) else { return false }

        if tradeObjectDate > Date() {
            return true
        }
        
        return false
    }
    
    func getTradeObjects() async {
        let result = await APIManager().fetchDataWithParameters(type: TradeObjects.self,
                                                                    endpoint: .tradeObjects)
        switch result {
        case .success(let success):
            tradeObjects = success.row
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
    }
    
    func getTradeObjectsType() async {
        let result = await APIManager().fetchDataWithParameters(type: TradeObjectType.self,
                                                                    endpoint: .tradeObjectsGetType)
        switch result {
        case .success(let success):
            tradeObjectsType = success.row
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
    }
    
    func getTradeObjectsPeriod() async {
        let result = await APIManager().fetchDataWithParameters(type: TradeObjectPeriod.self,
                                                                    endpoint: .tradeObjectsGetPeriod)
        switch result {
        case .success(let success):
            tradeObjectsPeriod = success.row
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
    }
    
    func getFilteredTradeObjectByFilter(_ searchFilter: TradeObjectsSearch) async -> [TradeObjectsRow]? {
        let result = await APIManager().fetchDataWithParameters(type: TradeObjects.self,
                                                                    endpoint: .tradeObjectsSearch(search: searchFilter))
        switch result {
        case .success(let success):
            return success.row
        case .failure(let failure):
            print(failure)
            onError?(failure)
            return nil
        }
    }
    
    func getTradeObjectById(_ id: String) async -> TradeObject? {
        let result = await APIManager().fetchDataWithParameters(type: TradeObject.self,
                                                                    endpoint: .tradeObjectBy(id: id))
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            print(failure)
            onError?(failure)
            return nil
        }
    }
    
    func addAnnotations(tradeObjects: [TradeObjectsRow]) -> [MKTradeObjectAnnotation] {
        var annotations = [MKTradeObjectAnnotation]()
        
        tradeObjects.forEach { object in
            var stringCoordinates = object.fields.mark
            stringCoordinates.removeFirst()
            stringCoordinates.removeLast()
            print(stringCoordinates)
            let coordinates = stringCoordinates.components(separatedBy: ",")
            let lat = Double(coordinates.first ?? "") ?? 0
            let long = Double(coordinates.last ?? "") ?? 0
            
            let numDocument = object.fields.numDoc
            let tradeType = isTradeObjectDateGreaterThanToday(object.fields.date, numberDocument: numDocument)
            
            let annotation = MKTradeObjectAnnotation(id: object.id, address: object.fields.address, coordinates: .init(latitude: lat, longitude: long), tradeType: tradeType)
            
            annotations.append(annotation)
        }
                
        return annotations
    }
    
}
