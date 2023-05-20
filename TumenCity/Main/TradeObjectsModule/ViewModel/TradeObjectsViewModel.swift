//
//  TradeObjectsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation

protocol TradeObjectsViewModelDelegate: AnyObject {
    func didFinishAddingAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation])
}

@MainActor
final class TradeObjectsViewModel {
    
    var tradeObjects = [TradeObjectsRow]()
    var tradeObjectsAnnotations = [MKTradeObjectAnnotation]()
    
    weak var delegate: TradeObjectsViewModelDelegate?
    
    init() {
        Task {
            await getTradeObjects()
            addAnnotations()
            print(createToken())
            delegate?.didFinishAddingAnnotations(tradeObjectsAnnotations)
        }
    }
    
    func isTradeObjectDateGreaterThanToday(_ strDate: String?) -> Bool {
        guard let strDate else { return false }
        
        let date = DateFormatter()
        date.dateFormat = "dd-MM-yyyy"
        
        guard let tradeObjectDate = date.date(from: strDate) else { return false}

        if tradeObjectDate > Date() {
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
    
    func getTradeObjectById(_ id: String) async -> TradeObject? {
        do {
            let result = try await APIManager().getAPIContent(type: TradeObject.self, endpoint: .tradeObjectBy(id: id))
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    func addAnnotations() {
        tradeObjects.forEach { object in
            var stringCoordinates = object.fields.mark
            stringCoordinates.removeFirst()
            stringCoordinates.removeLast()
            
            let coordinates = stringCoordinates.components(separatedBy: ",")
            let lat = Double(coordinates.first ?? "") ?? 0
            let long = Double(coordinates.last ?? "") ?? 0
            
            let tradeType = isTradeObjectDateGreaterThanToday(object.fields.date)
            
            let annotation = MKTradeObjectAnnotation(id: object.id, coordinates: .init(latitude: lat, longitude: long), tradeType: tradeType)
            
            tradeObjectsAnnotations.append(annotation)
        }
    }
    
}
