//
//  CityCleaningFilterViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import RxSwift
import RxRelay

@MainActor
final class CityCleaningFilterViewModel {
    
    var filterItems = [CityCleaningTypeElement]()
    var contractorsItems = [CityCleaningContractorElement]()
    private var isLoading = BehaviorRelay(value: false)
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            isLoading.accept(true)
            await getFilterItems()
            await getContractorsItems()
            isLoading.accept(false)
        }
    }
    
    func getFilterItems() async {
        let result = await APIManager().fetchDataWithParameters(type: [CityCleaningTypeElement].self,
                                                                    endpoint: .cityCleaningType)
        switch result {
        case .success(let success):
            filterItems = success
        case .failure(let failure):
            print(failure)
        }
    }
    
    func getContractorsItems() async {
        let result = await APIManager().fetchDataWithParameters(type: [CityCleaningContractorElement].self,
                                                                    endpoint: .cityCleaningContractor)
        switch result {
        case .success(let success):
            contractorsItems = success
        case .failure(let failure):
            print(failure)
        }
    }
}
