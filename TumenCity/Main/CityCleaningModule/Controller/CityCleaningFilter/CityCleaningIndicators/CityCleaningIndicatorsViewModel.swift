//
//  CityCleaningIndicatorsViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 23.07.2023.
//

import Foundation
import RxSwift

@MainActor
final class CityCleaningIndicatorsViewModel {
    
    private var indicators: CityCleaningIndicator?
    private var indicatorsItems = [CityCleaningIndicatorItem]()
    
    func getIndicatorItemByIndex(_ index: Int) -> CityCleaningIndicatorItem {
        indicatorsItems[index]
    }
    
    func getIndicators() -> Observable<Void> {
        return Observable.create { observer in
            Task { [weak self] in
                do {
                    let indicators = try await APIManager().getAPIContent(type: CityCleaningIndicator.self, endpoint: .cityCleaningIndicator)
                    self?.indicators = indicators
                    self?.createItems()
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    print(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func createItems() {
        if let item = indicators?.all {
            let indicatorItem = CityCleaningIndicatorItem(idCouncil: nil, council: "Город",
                                                           timelinessData: item.timelinessData,
                                                           activeDuringDay: item.activeDuringDay,
                                                           countContractor: item.countContractor,
                                                           sumMorning: item.sumMorning,
                                                           sumNight: item.sumNight,
                                                           detal: nil, timelinessDataCount: nil)
            indicatorsItems.append(indicatorItem)
        }

        indicators?.ao.forEach { item in
            let indicatorItem = CityCleaningIndicatorItem(idCouncil: item.idCouncil, council: item.council,
                                                           timelinessData: item.timelinessData,
                                                           activeDuringDay: item.activeDuringDay,
                                                           countContractor: item.countContractor,
                                                           sumMorning: item.sumMorning,
                                                           sumNight: item.sumNight,
                                                           detal: item.detal, timelinessDataCount: nil)
            indicatorsItems.append(indicatorItem)
        }
    }
    
}
