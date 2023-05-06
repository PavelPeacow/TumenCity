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
    
    var url: URL? {
        
        switch self {
            
        case .communalServices:
            return urlComponents(path: "/cron/mkd.t-c.ru.php")
            
        case .closeRoads:
            return urlComponents(host: "api.tgt72.ru", path: "/api/v5/roadworks")
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
        }
        print()
        print("url \(request.url)")
        return request
    }
}
