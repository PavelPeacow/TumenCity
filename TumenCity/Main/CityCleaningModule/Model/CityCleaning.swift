//
//  CityCleaning.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import Foundation

// MARK: - CityCleaningItem
struct CityCleaning: Codable {
    let info: [CityCleaningItemInfo]
    let featureCollection: CityCleaningItemFeatureCollection
}

// MARK: - FeatureCollection
struct CityCleaningItemFeatureCollection: Codable {
    let type: String
    let features: [CityCleaningItemFeature]
}

// MARK: - Feature
struct CityCleaningItemFeature: Codable {
    let type: FeatureType
    let id: Int
    let geometry: CityCleaningItemGeometry
    let options: CityCleaningItemOptions
}

// MARK: - Geometry
struct CityCleaningItemGeometry: Codable {
    let coordinates: [Double]
    let type: String
}

// MARK: - Options
struct CityCleaningItemOptions: Codable {
    let id: Int
    let contractor: String
    let imgType: String
    let iconLayout: String
    let iconImageHref: String
    let iconImageSize, iconImageOffset: [Int]
}

// MARK: - Info
struct CityCleaningItemInfo: Codable {
    let id: Int
    let gps: [Double]
    let guid: GUID
    let contractor: String
    let number: String?
    let type: String
    let speed: Int?
    let dtime: String
    let course: Int?
    let council: String
    let icon: CityCleaningItemIcon

    enum CodingKeys: String, CodingKey {
        case id, gps, guid, contractor, number, type, speed, dtime, course, council, icon
    }
}

enum CityCleaningItemIcon: String, Codable {
    case modulesGraderNewImgTypesType11SVG = "/modules/grader_new/img/types/type-11.svg"
    case modulesGraderNewImgTypesType12SVG = "/modules/grader_new/img/types/type-12.svg"
    case modulesGraderNewImgTypesType1SVG = "/modules/grader_new/img/types/type-1.svg"
    case modulesGraderNewImgTypesType2SVG = "/modules/grader_new/img/types/type-2.svg"
    case modulesGraderNewImgTypesType3SVG = "/modules/grader_new/img/types/type-3.svg"
    case modulesGraderNewImgTypesType4SVG = "/modules/grader_new/img/types/type-4.svg"
    case modulesGraderNewImgTypesType6SVG = "/modules/grader_new/img/types/type-6.svg"
    case modulesGraderNewImgTypesType8SVG = "/modules/grader_new/img/types/type-8.svg"
}

enum GUID: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(GUID.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for GUID"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
