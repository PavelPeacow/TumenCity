//
//  APIEndpoint.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

enum APIEndpoint {
    case communalServices
    case closeRoads
    case sport
    
    case tradeObjects
    case tradeObjectBy(id: String)
    
    var url: URL? {
        
        switch self {
            
        case .communalServices:
            return urlComponents(path: "/cron/mkd.t-c.ru.php")
            
        case .closeRoads:
            return urlComponents(host: "api.tgt72.ru", path: "/api/v5/roadworks")
            
        case .sport:
            return urlComponents(host: "info.agt72.ru", path: "/api/sport/main/institutions/json")
            
        case .tradeObjects:
            return urlComponents(host: "nto.tyumen-city.ru", path: "/api/informer/MobileAppInfo/select/json")
            
        case .tradeObjectBy:
            return urlComponents(host: "nto.tyumen-city.ru", path: "/api/informer/MobileAppInfo/selectById/json")
        }
        
    }
    
    func urlComponents(scheme: String = "https", host: String = "dom.tyumen-city.ru", path: String, queryItems: [URLQueryItem]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
    
    func request(url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        
        switch self {
            
        case .communalServices:
            break
        case .closeRoads:
            request.httpMethod = "POST"
            
            let formData = "token=\(createToken())"
            request.httpBody = formData.data(using: .utf8)
            print(createToken())
            
        case .sport:
            break
            
        case .tradeObjects:
            request.httpMethod = "POST"
            
            let formData = "token=\(createToken())"
            request.httpBody = formData.data(using: .utf8)
            print(createToken())
            
        case .tradeObjectBy(let id):
            request.httpMethod = "POST"
            
            let formData = [
                "token" : createToken(),
                "id" : id
            ].map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            
            request.httpBody = formData.data(using: .utf8)
            print(createToken())
            
        }

        print("url \(request.url)")
        return request
    }
}
