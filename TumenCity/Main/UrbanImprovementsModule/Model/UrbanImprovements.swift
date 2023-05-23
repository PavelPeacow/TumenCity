//
//  UrbanImprovements.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import Foundation

// MARK: - UrbanImprovements
struct UrbanImprovements: Codable {
    let geo: Geo
    let filter: [Filter]
}

// MARK: - Filter
struct Filter: Codable {
    let id: Int
    let type, title, nameJSON: String
    let item: [FilterItem]

    enum CodingKeys: String, CodingKey {
        case id, type, title
        case nameJSON = "name_json"
        case item
    }
}

// MARK: - Item
struct FilterItem: Codable {
    let id: Int
    let item: String
}

// MARK: - Geo
struct Geo: Codable {
    let points: Points
    let polygons: Polygons
}

// MARK: - Points
struct Points: Codable {
    let type: String
    let features: [PointsFeature]
}

// MARK: - PointsFeature
struct PointsFeature: Codable {
    let type: FeatureType
    let id: Int
    let geometry: PurpleGeometry
    let options: PurpleOptions
    let properties: UrbanImprovementsProperties
}

// MARK: - PurpleGeometry
struct PurpleGeometry: Codable {
    let type: PurpleType
    let coordinates: [Double]
}

enum PurpleType: String, Codable {
    case point = "Point"
}

// MARK: - PurpleOptions
struct PurpleOptions: Codable {
    let iconLayout, iconLayoutOld: UrbanImprovementsIconLayout
    let preset: Preset
    let iconOffset: [Int]
    let iconShape: UrbanImprovementsIconShape
}

enum UrbanImprovementsIconLayout: String, Codable {
    case iconMark10 = "icon#mark-10"
    case iconMark11 = "icon#mark-11"
    case iconMark12 = "icon#mark-12"
    case iconMark15 = "icon#mark-15"
    case iconMark62 = "icon#mark-62"
    case iconMark63 = "icon#mark-63"
    case iconMark9 = "icon#mark-9"
}

// MARK: - IconShape
struct UrbanImprovementsIconShape: Codable {
    let type: IconShapeType
    let coordinates: [[Int]]
}

enum IconShapeType: String, Codable {
    case rectangle = "Rectangle"
}

enum Preset: String, Codable {
    case islandsBlueCircleDotIconWithCaption = "islands#blueCircleDotIconWithCaption"
    case islandsGreenCircleDotIconWithCaption = "islands#greenCircleDotIconWithCaption"
    case islandsLightBlueCircleDotIconWithCaption = "islands#lightBlueCircleDotIconWithCaption"
    case islandsNightCircleDotIconWithCaption = "islands#nightCircleDotIconWithCaption"
    case islandsOrangeCircleDotIconWithCaption = "islands#orangeCircleDotIconWithCaption"
    case islandsRedCircleDotIconWithCaption = "islands#redCircleDotIconWithCaption"
    case islandsVioletCircleDotIconWithCaption = "islands#violetCircleDotIconWithCaption"
}

// MARK: - Properties
struct UrbanImprovementsProperties: Codable {
    let id: Int
    let title: String
}

enum UrbanImprovementsFeatureType: String, Codable {
    case feature = "Feature"
}

// MARK: - Polygons
struct Polygons: Codable {
    let type: String
    let features: [PolygonsFeature]
}

// MARK: - PolygonsFeature
struct PolygonsFeature: Codable {
    let type: FeatureType
    let id: Int
    let geometry: FluffyGeometry
    let options: FluffyOptions
    let properties: UrbanImprovementsProperties
}

// MARK: - FluffyGeometry
struct FluffyGeometry: Codable {
    let type: FluffyType
    let coordinates: [[[Double]]]
}

enum FluffyType: String, Codable {
    case polygon = "Polygon"
}

// MARK: - FluffyOptions
struct FluffyOptions: Codable {
    let strokeColor: Color
    let strokeWidth, strokeOpacity, fillOpacity: Int
    let fillColor: Color
    let draggable: Bool
    let id: Int
}

enum Color: String, Codable {
    case ff495F70 = "#FF495F70"
    case the0383E070 = "#0383E070"
    case the0Fb73E70 = "#0FB73E70"
    case the32Daff = "#32DAFF"
    case the9B51E070 = "#9B51E070"
}
