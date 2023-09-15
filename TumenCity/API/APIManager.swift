//
//  APIManager.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

enum APIConstant {
    static let shaKey = "M0b!1e@pp!nf0!ntegr@t!0ne_crm2O23"
}

enum APIError: LocalizedError {
    case badURL
    case cannotCreateRequest
    case cannotGet
    case cannotDecode
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Не удалость установить соединение с адресом!"
        case .cannotCreateRequest:
            return "Не удалось создать запрос к серверу!"
        case .cannotGet:
            return "Не удалось получить данные с сервера!"
        case .cannotDecode:
            return "Не удалость декодировать полученные данные с сервера!"
        }
    }
}

final class APIManager {
    
    private let jsonDecoder: JSONDecoder
    private let urlSession: URLSession
    
    init(jsonDecoder: JSONDecoder = .init(), urlSession: URLSession = .shared) {
        self.jsonDecoder = jsonDecoder
        self.urlSession = urlSession
    }
    
    func getAPIContent<T: Decodable>(type: T.Type, endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else { throw APIError.badURL }
        
        guard let requst = endpoint.request(url: url) else { throw APIError.cannotCreateRequest }
        
        guard let (data, _) = try? await urlSession.data(for: requst) else { throw APIError.cannotGet }
        
//        print(String(data: data, encoding: .utf8))Тщ
            
        guard let result = try? jsonDecoder.decode(T.self, from: data) else { throw APIError.cannotDecode }
        
        return result
    }
    
    func decodeMock<T: Decodable>(type: T.Type, forResourse: String) async -> T {
        let url = Bundle.main.url(forResource: forResourse, withExtension: "json")!
        
        let data = try! Data(contentsOf: url)
        
        return try! jsonDecoder.decode(T.self, from: data)
    }
    
}
