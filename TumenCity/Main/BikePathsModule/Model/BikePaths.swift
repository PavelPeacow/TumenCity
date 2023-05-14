//
//  BikePaths.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation

// MARK: - BikePaths
struct BikePaths: Codable {
    let row: Row
}

// MARK: - Row
struct Row: Codable {
    let object: [Object]
    let line: [Line]
}

// MARK: - Object
struct Object: Codable {
    let id: Int
    let fields: ObjectFields
}

// MARK: - ObjectFields
struct ObjectFields: Codable {
    let title, poligon: String
}


// MARK: - Line
struct Line: Codable {
    let id: Int
    let fields: LineFields
}

// MARK: - LineFields
struct LineFields: Codable {
    let title: String
    let typeCollor: TypeCollor?
    let polyline: String

    enum CodingKeys: String, CodingKey {
        case title
        case typeCollor = "type_collor"
        case polyline
    }
}

// MARK: - TypeCollor
struct TypeCollor: Codable {
    let id: Int
    let value: String
}
