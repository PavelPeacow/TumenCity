//
//  MainMenuRoutercase swift
//  TumenCity
//
//  Created by Павел Кай on 21.09.2023.
//

import UIKit

enum MainMenuRouterPaths {
    case sport
    case cityCleaning
    case bikePaths
    case urbanImprovements
    case communalServices
    case roadClose
    case digWork
    case tradeObjects
}

protocol MainMenuRouterProtocol {
    func navigateTo(path: MainMenuRouterPaths, from controller: UIViewController)
}

final class MainMenuRouter: MainMenuRouterProtocol {
    private let builder: MainMenuBuilderProtocol
    
    init(builder: MainMenuBuilderProtocol) {
        self.builder = builder
    }
    
    func navigateTo(path: MainMenuRouterPaths, from controller: UIViewController) {
        let builtController = switch path {
        case .sport:
            builder.buildSportModule()
        case .cityCleaning:
            builder.buildCityCleaningModule()
        case .bikePaths:
            builder.buildBikePathsModule()
        case .urbanImprovements:
            builder.buildUrbanImprovementsModule()
        case .communalServices:
            builder.buildCommunalServicesModule()
        case .roadClose:
            builder.buildCloseRoadsModule()
        case .digWork:
            builder.buildDigWorkModule()
        case .tradeObjects:
            builder.buildTradeObjectsModule()
        }
        controller.navigationController?.pushViewController(builtController, animated: true)
    }
    
}
