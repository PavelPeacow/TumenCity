//
//  TradeObjectsPeriod.swift
//  TumenCity
//
//  Created by Павел Кай on 21.05.2023.
//

import Foundation

// MARK: - TradeObjectPeriod
struct TradeObjectPeriod: Codable {
    let row: [TradeObjectPeriodRow]
}

// MARK: - Row
struct TradeObjectPeriodRow: Codable {
    let id, sort, title: String
}
