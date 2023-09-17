//
//  APIManager.swift
//  TumenCity
//
//  Created by Павел Кай on 15.09.2023.
//

import Foundation
import Alamofire
import UIKit

protocol APIManagerProtocol {
    associatedtype T
    func fetchDataWithParameters<T: Codable>(type: T.Type,
                                             endpoint: Endpoint
    ) async -> Result<T, AFError>
}

final class APIManager: APIManagerProtocol {
    typealias T = Codable
    
    private let sessionConfiguration: URLSessionConfiguration
    private let sessionManager: Session
    
    init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.sessionConfiguration = sessionConfiguration
        self.sessionManager = Session(configuration: sessionConfiguration)
    }
    
    func fetchDataWithParameters<T: Codable>(type: T.Type,
                                             endpoint: Endpoint
    ) async -> Result<T, AFError> {
        await sessionManager.request(endpoint.url,
                                     method: endpoint.method,
                                     parameters: endpoint.parameters,
                                     encoding: endpoint.encodingType)
        .validate()
        .cURLDescription(calling: { debug in
            print(debug)
        })
        .serializingDecodable(T.self)
        .result
    }
}
