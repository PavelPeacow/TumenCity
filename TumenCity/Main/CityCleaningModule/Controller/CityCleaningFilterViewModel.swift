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
    private var isLoading = BehaviorRelay(value: false)
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            isLoading.accept(true)
            await getFilterItems()
            isLoading.accept(false)
        }
    }
    
    func getFilterItems() async {
        do {
            let res = try await APIManager().getAPIContent(type: [CityCleaningTypeElement].self, endpoint: .cityCleaningType)
            filterItems = res
        } catch {
            print(error)
        }
    }
    
}
