//
//  APIManager.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

enum APIError: Error {
    case badURL
    case cannotCreateRequest
    case cannotGet
    case cannotDecode
}

final class APIManager {
    
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession
    
    init(jsonDecoder: JSONDecoder = .init(), urlSession: URLSession = .shared) {
        self.jsonDecoder = jsonDecoder
        self.urlSession = urlSession
        
        print("----shaKey----")
        print(sha256(string: "20230105123456"))
    }
    
    func getAPIContent<T: Decodable>(type: T.Type, endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else { throw APIError.badURL }
        
        guard let requst = endpoint.request(url: url) else { throw APIError.cannotCreateRequest }
        
        guard let (data, _) = try? await urlSession.data(for: requst) else { throw APIError.cannotGet }
        
        guard let result = try? jsonDecoder.decode(T.self, from: data) else { throw APIError.cannotDecode }
        
        return result
    }
    
}
