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
                let indicators = await self?.getIndicatorsData()
                self?.indicators = indicators
                self?.createItems()
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func getIndicatorsData() async -> CityCleaningIndicator? {
        let result = await APIManager().fetchDataWithParameters(type: CityCleaningIndicator.self,
                                                                    endpoint: .cityCleaningIndicator)
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            print(failure)
            return nil
        }
    }
    
    private func createItems() {
        if let item = indicators?.all {
            let indicatorItem = CityCleaningIndicatorItem(idCouncil: nil, council: L10n.CityCleaning.Indicator.Callout.councilPlaceholder,
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
