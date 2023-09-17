//
//  TradeObjects.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation

// MARK: - TradeObjects
struct TradeObjects: Codable {
    let row: [TradeObjectsRow]
}

// MARK: - Row
struct TradeObjectsRow: Codable {
    let id: String
    let fields: Fields
}

// MARK: - Fields
struct Fields: Codable {
    let numDoc: String?
    let address, mark: String
    let object: String
    let spurpose: String
    let date: String?
}
