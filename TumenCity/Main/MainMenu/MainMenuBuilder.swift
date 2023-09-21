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
    
    func buildCityCleaningModule() -> CityCleaningViewController {
        .init()
    }
    
    func buildBikePathsModule() -> BikePathsViewController {
        .init()
    }
    
    func buildUrbanImprovementsModule() -> UrbanImprovementsViewController {
        .init()
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
    
    func buildDigWorkModule() -> DigWorkViewController {
        .init()
    }
    
    func buildTradeObjectsModule() -> TradeObjectsViewController {
        .init()
    }
}
