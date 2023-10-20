//
//  MainMenuBuilder.swift
//  TumenCity
//
//  Created by Павел Кай on 21.09.2023.
//

import UIKit

protocol MainMenuBuilderProtocol {
    func buildSportModule() -> SportViewController
    func buildCityCleaningModule() -> CityCleaningViewController
    func buildBikePathsModule() -> BikePathsViewController
    func buildUrbanImprovementsModule() -> UrbanImprovementsViewController
    func buildCommunalServicesModule() -> CommunalServicesViewController
    func buildCloseRoadsModule() -> CloseRoadsViewController
    func buildDigWorkModule() -> DigWorkViewController
    func buildTradeObjectsModule() -> TradeObjectsViewController
}

final class MainMenuBuilder: MainMenuBuilderProtocol {
    func buildSportModule() -> SportViewController {
        let registryView = SportRegistryView()
        let searchResult = SportRegistrySearchViewController()
        return SportViewController(sportRegistryView: registryView, sportRegistrySearchResult: searchResult)
    }
    
    @MainActor func buildCityCleaningModule() -> CityCleaningViewController {
        let viewModel = CityCleaningViewModel()
        return .init(viewModel: viewModel)
    }
    
    @MainActor func buildBikePathsModule() -> BikePathsViewController {
        let viewModel = BikePathsViewModel()
        return .init(viewModel: viewModel)
    }
    
    @MainActor func buildUrbanImprovementsModule() -> UrbanImprovementsViewController {
        let viewModel = UrbanImprovementsViewModel()
        return .init(viewModel: viewModel)
    }
    
    func buildCommunalServicesModule() -> CommunalServicesViewController {
        let serviceMap = CommunalServicesView()
        let serviceRegistry = RegistryView()
        let serviceSearch = RegistySearchResultViewController()
        return CommunalServicesViewController(serviceMap: serviceMap, serviceRegistry: serviceRegistry, serviceSearch: serviceSearch)
    }
    
    func buildCloseRoadsModule() -> CloseRoadsViewController {
        .init()
    }
    
    @MainActor func buildDigWorkModule() -> DigWorkViewController {
        let viewModel = DigWorkViewModel()
        return .init(viewModel: viewModel)
    }
    
    func buildTradeObjectsModule() -> TradeObjectsViewController {
        .init()
    }
}
