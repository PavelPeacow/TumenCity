//
//  DigWork.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import Foundation

// MARK: - DigWork
struct DigWork: Codable {
    let type: String
    let features: [DigWorkElement]
}

// MARK: - Feature
struct DigWorkElement: Codable {
    let geometry: DigWorkGeometry
    let info: DigWorkInfo
    let options: Options
    let type: FeatureType?
    let id: Int
}

// MARK: - Geometry
struct DigWorkGeometry: Codable {
    let coordinates: [Double]?
    let type: GeometryType?
}

enum GeometryType: String, Codable {
    case point = "Point"
}

// MARK: - Info
struct DigWorkInfo: Codable {
    let balloonContentHeader, balloonContentBody: String
    let hintContent: String?
}

// MARK: - Options
struct Options: Codable {
    let address: String?
    let iconLayout: IconLayout
    let iconImageHref: IconImageHref
    let iconImageSize, iconImageOffset: [Int]
}

enum IconImageHref: String, Codable {
    case modulesDigImgLogoMarkSVG = "/modules/dig/img/logo-mark.svg"
}

enum IconLayout: String, Codable {
    case defaultImage = "default#image"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

