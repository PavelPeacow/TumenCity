//
//  TradeObjects.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation

// MARK: - TradeObjects
struct TradeObjects: Decodable {
    let row: [TradeObjectsRow]
}

// MARK: - Row
struct TradeObjectsRow: Decodable {
    let id: String
    let fields: Fields
}

// MARK: - Fields
struct Fields: Decodable {
    let numDoc: String?
    let address, mark: String
    let object: String
    let spurpose: String
    let date: String?
}
