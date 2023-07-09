//
//  TradeObjectsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation
import RxSwift
import RxRelay

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
        do {
            let result = try await APIManager().getAPIContent(type: TradeObjects.self, endpoint: .tradeObjects)
            tradeObjects = result.row
        } catch {
            print(error)
        }
    }
    
    func getTradeObjectsType() async {
        do {
            let result = try await APIManager().getAPIContent(type: TradeObjectType.self, endpoint: .tradeObjectsGetType)
            tradeObjectsType = result.row
        } catch {
            print(error)
        }
    }
    
    func getTradeObjectsPeriod() async {
        do {
            let result = try await APIManager().getAPIContent(type: TradeObjectPeriod.self, endpoint: .tradeObjectsGetPeriod)
            tradeObjectsPeriod = result.row
        } catch {
            print(error)
        }
    }
    
    func getFilteredTradeObjectByFilter(_ searchFilter: TradeObjectsSearch) async -> [TradeObjectsRow]? {
        do {
            let result = try await APIManager().getAPIContent(type: TradeObjects.self, endpoint: .tradeObjectsSearch(search: searchFilter))
            return result.row
        } catch {
            print(error)
            return nil
        }
    }
    
    func getTradeObjectById(_ id: String) async -> TradeObject? {
        do {
            let result = try await APIManager().getAPIContent(type: TradeObject.self, endpoint: .tradeObjectBy(id: id))
            return result
        } catch {
            print(error)
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
