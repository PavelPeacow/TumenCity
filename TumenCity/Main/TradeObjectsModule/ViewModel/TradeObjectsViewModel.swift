//
//  TradeObjectsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation
import Alamofire
import Combine

@MainActor
final class TradeObjectsViewModel {
    
    @Published var currentVisibleTradeObjectsAnnotations = [MKTradeObjectAnnotation]()
    
    var tradeObjects = [TradeObjectsRow]()
    @Published var tradeObjectsAnnotations = [MKTradeObjectAnnotation]()
    
    var tradeObjectsType = [TradeObjectTypeRow]()
    var tradeObjectsPeriod = [TradeObjectPeriodRow]()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published private var isLoading = true
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var currentVisibleTradeObjectsAnnotationsObservable: AnyPublisher<[MKTradeObjectAnnotation], Never> {
        $currentVisibleTradeObjectsAnnotations.eraseToAnyPublisher()
    }
    
    var tradeObjectsAnnotationsObservable: AnyPublisher<[MKTradeObjectAnnotation], Never> {
        $tradeObjectsAnnotations.eraseToAnyPublisher()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getTradeObjectsData()
        }
    }
    
    func getDefualtTradeAnnotations() -> [MKTradeObjectAnnotation] {
        tradeObjectsAnnotations
    }
    
    func getCurrentVisibleTradeAnnotations() -> [MKTradeObjectAnnotation] {
        currentVisibleTradeObjectsAnnotations
    }
    
    func filterAnnotationsByType(_ type: MKTradeObjectAnnotation.AnnotationType) -> [MKTradeObjectAnnotation] {
        currentVisibleTradeObjectsAnnotations.filter { $0.type == type }
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
    
    func getTradeObjectsData() async {
        isLoading = true
        async let tradeObjectsPublisher = getTradeObjects()
        async let tradeObjectsTypePublisher = getTradeObjectsType()
        async let tradeObjectsPeriodPublisher = getTradeObjectsPeriod()
        
        Publishers
            .CombineLatest3(await tradeObjectsPublisher, await tradeObjectsTypePublisher, await tradeObjectsPeriodPublisher)
            .sink(receiveCompletion: { [unowned self] completion in
                isLoading = false
                if case let .failure(error) = completion {
                    self.onError?(error)
                }
            }) { [unowned self] trade, tradeType, tradePeriod in
                tradeObjects = trade.row
                tradeObjectsType = tradeType.row
                tradeObjectsPeriod = tradePeriod.row
                
                let annotations = self.addAnnotations(tradeObjects: tradeObjects)
                
                self.tradeObjectsAnnotations = annotations
                self.currentVisibleTradeObjectsAnnotations = annotations
            }
            .store(in: &cancellables)
    }
    
    func getTradeObjects() async -> Result<TradeObjects, AFError>.Publisher {
        await APIManager()
            .fetchDataWithParameters(type: TradeObjects.self, endpoint: .tradeObjects)
            .publisher
    }
    
    func getTradeObjectsType() async -> Result<TradeObjectType, AFError>.Publisher {
        await APIManager()
            .fetchDataWithParameters(type: TradeObjectType.self, endpoint: .tradeObjectsGetType)
            .publisher
    }
    
    func getTradeObjectsPeriod() async -> Result<TradeObjectPeriod, AFError>.Publisher {
        await APIManager()
            .fetchDataWithParameters(type: TradeObjectPeriod.self, endpoint: .tradeObjectsGetPeriod)
            .publisher
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
            let coordinates = stringCoordinates
                .replacingOccurrences(of: " ", with: "")
                .components(separatedBy: ",")
            
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
