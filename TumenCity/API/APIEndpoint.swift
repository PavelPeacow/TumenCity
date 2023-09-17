//
//  APIEndpoint.swift
//  TumenCity
//
//  Created by Павел Кай on 17.09.2023.
//

import Alamofire

enum Endpoint {
    case communalServices
    case closeRoads
    case sport
    case digWork(filter: DigWorkFilter? = nil)
    
    case tradeObjects
    case tradeObjectBy(id: String)
    case tradeObjectsGetType
    case tradeObjectsGetPeriod
    case tradeObjectsSearch(search: TradeObjectsSearch)
    
    case urbanImprovements
    case urbanImprovementsInfo(id: Int)
    
    case cityCleaning
    case cityCleaningType
    case cityCleaningContractor
    case cityCleaningIndicator
    
    case bikePath
    case bikeLegend
    
    var url: String {
        switch self {
        case .closeRoads:
            "https://api.tgt72.ru/api/v5/roadworks"
        case .communalServices:
            "https://dom.tyumen-city.ru/cron/mkd.t-c.ru.php"
        case .sport:
            "https://info.agt72.ru/api/sport/main/institutions/json"
        case .digWork:
            "https://info.agt72.ru/api/dig/main/dig/json"
        case .tradeObjects:
            "https://nto.tyumen-city.ru/api/informer/MobileAppInfo/select/json"
        case .tradeObjectBy:
            "https://nto.tyumen-city.ru/api/informer/MobileAppInfo/selectById/json"
        case .tradeObjectsGetType:
            "https://nto.tyumen-city.ru/api/informer/MobileAppInfo/getTypeObject/json"
        case .tradeObjectsGetPeriod:
            "https://nto.tyumen-city.ru/api/informer/MobileAppInfo/getPeriod/json"
        case .tradeObjectsSearch:
            "https://nto.tyumen-city.ru/api/informer/MobileAppInfo/searchByCategory/json"
        case .urbanImprovements:
            "https://info.agt72.ru/api/informer/blagoustroystvo/select/json"
        case .urbanImprovementsInfo:
            "https://info.agt72.ru/api/informer/main/get_record_id/json"
        case .cityCleaning:
            "https://info.agt72.ru/api/grader_new/default/select/json"
        case .cityCleaningType:
            "https://info.agt72.ru/api/grader_new/default/type/json"
        case .cityCleaningContractor:
            "https://info.agt72.ru/api/grader_new/default/contractor/json"
        case .cityCleaningIndicator:
            "https://info.agt72.ru/api/grader_new/default/indicators/json"
        case .bikePath:
            "https://info.agt72.ru/api/informer/MobileAppInfo/select/json"
        case .bikeLegend:
            "https://info.agt72.ru/api/informer/MobileAppInfo/getLegenda/json"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .closeRoads, .tradeObjects, .tradeObjectsGetType, .tradeObjectsGetPeriod:
            return ["token": createToken()]
            
        case .digWork(filter: let filter):
            if let filter {
                let formData = [
                    "person" : filter.person,
                    "zone": filter.zone,
                    "missionType": filter.missionType,
                    "state": filter.state,
                    "startWorkTime": filter.startWorkTime,
                    "endWorkTime": filter.endWorkTime
                ]
                return formData
            } else {
                return nil
            }
            
        case .tradeObjectBy(id: let id):
            return ["token" : createToken(), "id" : id]
            
        case .tradeObjectsSearch(search: let search):
            let periodOperation = search.periodOperation!.isEmpty ? "periodOperation" : "periodOperation[]"
            let objectType = search.objectType!.isEmpty ? "objectType" : "objectType[]"

            let formData = [
                "token" : createToken(),
                periodOperation: search.periodOperation ?? "",
                objectType: search.objectType ?? "",
                "locationAddress": search.locationAddress,
                "numberObjectScheme": search.numberObjectScheme,
                "intendedPurpose": search.intendedPurpose
            ]
            return formData
            
        case .urbanImprovementsInfo(id: let id):
            return ["id": id]
            
        default:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .communalServices:
            return HTTPMethod.get
        default:
            return HTTPMethod.post
        }
    }
    
    var encodingType: ParameterEncoding {
        switch self {
        case .closeRoads, .tradeObjects, .tradeObjectsGetType, .tradeObjectsGetPeriod, .digWork, .tradeObjectBy, .tradeObjectsSearch:
            return URLEncoding.httpBody
            
        case .communalServices, .sport, .cityCleaning, .cityCleaningType,
                .cityCleaningContractor, .cityCleaningIndicator, .bikePath, .bikeLegend, .urbanImprovements:
            return URLEncoding.default
            
        case .urbanImprovementsInfo:
            return URLEncoding.queryString
        }
    }
}
