//
//  NetworkReachability.swift
//  TumenCity
//
//  Created by Павел Кай on 23.09.2023.
//

import Foundation
import Alamofire

final class NetworkReachability {
    static let shared = NetworkReachability()
    
    private let manager: NetworkReachabilityManager? = .init(host: "www.apple.com")
    private var initialAvailable = true
    
    var becomeAvailable: (() -> Void)?
    var becomeUnavailable: (() -> Void)?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        manager?.startListening(onUpdatePerforming: { [] status in
            switch status {
            case .reachable(_):
                guard !self.initialAvailable else { return }
                self.becomeAvailable?()
                self.initialAvailable = true
            case .notReachable, .unknown:
                self.becomeUnavailable?()
                self.initialAvailable = false
            }
        })
    }
}
