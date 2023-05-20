//
//  TradeObject.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import Foundation

struct TradeObject: Decodable {
    let row: [TradeObjectRow]
}

// MARK: - Row
struct TradeObjectRow: Decodable {
    let id: String
    let fields: TradeObjectFields
}

// MARK: - Fields
struct TradeObjectFields: Decodable {
    let numShema: String?
    let numDoc: String?
    let address: String?
    let detailAddress: String?
    let mark, okr, object, spurpose: String?
    let period, area: String?
    let floors: String?
    let height: String?
    let urName, date, img: String?
}
