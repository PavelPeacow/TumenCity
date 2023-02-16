//
//  APIEndpoint.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

enum APIEndpoint {
    case communalServices
    
    var url: URL? {
        
        switch self {
            
        case .communalServices:
            return urlComponents(path: "/cron/mkd.t-c.ru.php", queryItems: nil)
        }
        
    }
    
    func urlComponents(scheme: String = "https", host: String = "dom.tyumen-city.ru", path: String, queryItems: [URLQueryItem]?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
    
    func request(url: URL) -> URLRequest? {
        let request = URLRequest(url: url)
        
        return request
    }
}
