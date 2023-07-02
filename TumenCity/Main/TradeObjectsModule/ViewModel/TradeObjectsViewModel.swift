//
//  TradeObjectsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation
import RxSwift
import RxRelay

protocol TradeObjectsViewModelDelegate: AnyObject {
    func didFinishAddingAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation])
    func didFilterAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation])
}

@MainActor
final class TradeObjectsViewModel {
    
    var currentVisibleTradeObjectsAnnotations = [MKTradeObjectAnnotation]()
    
    var tradeObjects = [TradeObjectsRow]()
    var tradeObjectsAnnotations = [MKTradeObjectAnnotation]()
    
    var tradeObjectsType = [TradeObjectTypeRow]()
    var tradeObjectsPeriod = [TradeObjectPeriodRow]()
    
    weak var delegate: TradeObjectsViewModelDelegate?
    
    init() {
        Task {
            await getTradeObjects()
            await getTradeObjectsType()
            await getTradeObjectsPeriod()
            
            tradeObjectsAnnotations = addAnnotations(tradeObjects: tradeObjects)
            currentVisibleTradeObjectsAnnotations = tradeObjectsAnnotations
            
            print(createToken())
            delegate?.didFinishAddingAnnotations(currentVisibleTradeObjectsAnnotations)
        }
    }
    
    func filterAnnotationsByType(_ type: MKTradeObjectAnnotation.AnnotationType) {
        switch type {
        case .activeTrade:
            let filteredAnnotations = currentVisibleTradeObjectsAnnotations.filter { $0.type == .activeTrade }
            delegate?.didFilterAnnotations(filteredAnnotations)
        case .freeTrade:
            let filteredAnnotations = currentVisibleTradeObjectsAnnotations.filter { $0.type == .freeTrade }
            delegate?.didFilterAnnotations(filteredAnnotations)
        }
    }
    
    func isTradeObjectDateGreaterThanToday(_ strDate: String?) -> Bool {
        guard let strDate else { return false }
        
        let date = DateFormatter()
        date.dateFormat = "dd-MM-yyyy"
        
        guard let tradeObjectDate = date.date(from: strDate) else { return false}

        if tradeObjectDate >= Date() {
            return true
        }
        
        return false
    }
    
    func getTradeObjects() async {
        do {
            let result = await APIManager().decodeMock(type: TradeObjects.self, forResourse: "tradeObjectsMock")
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
            
            let coordinates = stringCoordinates.components(separatedBy: ",")
            let lat = Double(coordinates.first ?? "") ?? 0
            let long = Double(coordinates.last ?? "") ?? 0
            
            let tradeType = isTradeObjectDateGreaterThanToday(object.fields.date)
            
            let annotation = MKTradeObjectAnnotation(id: object.id, coordinates: .init(latitude: lat, longitude: long), tradeType: tradeType)
            
            annotations.append(annotation)
        }
                
        return annotations
    }
    
}
