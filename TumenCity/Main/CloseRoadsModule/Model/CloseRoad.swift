//
//  CloseRoad.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import Foundation

// MARK: - RoadCloseResponse
struct RoadCloseResponse: Codable {
    let total: Int
    let objects: [RoadCloseObject]
}

// MARK: - Object
struct RoadCloseObject: Codable {
    let comment, end, name: String
    let sign: Int
    let geomJSON: GeomJSON
    let start: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case comment, end, name, sign
        case geomJSON = "geom_json"
        case start, id
    }
}

// MARK: - GeomJSON
struct GeomJSON: Codable {
    let type: TypeEnum
    let coordinates: Coordinate
}

enum Coordinate: Codable {
    case double([Double])
    case doubleArrayArray([[[Double]]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([[[Double]]].self) {
            self = .doubleArrayArray(x)
            return
        }
        if let x = try? container.decode([Double].self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Coordinate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
    }
}

enum TypeEnum: String, Codable {
    case point = "Point"
    case polygon = "Polygon"
}
