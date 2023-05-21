//
//  TradeObjectsType.swift
//  TumenCity
//
//  Created by Павел Кай on 21.05.2023.
//

import Foundation

struct TradeObjectType: Codable {
    let row: [TradeObjectTypeRow]
}

// MARK: - Row
struct TradeObjectTypeRow: Codable {
    let id, sort, title: String
}
