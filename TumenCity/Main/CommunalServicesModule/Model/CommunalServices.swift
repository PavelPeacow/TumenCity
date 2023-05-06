//
//  CommunalServices.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

// MARK: - Mkd
struct CommunalServices: Codable {
    let info: [Info]
    let card: [Card]
    let mark: [Mark]
    let datetime: String
}

// MARK: - Card
struct Card: Codable {
    let numCard: Int
    let vidWork, datStart, datFinish, usOrg: String
    let planRab: Int
    let accident: [Accident]?
    let fkAddress: [FkAddress]?

    enum CodingKeys: String, CodingKey {
        case numCard = "num_card"
        case vidWork = "vid_work"
        case datStart = "dat_start"
        case datFinish = "dat_finish"
        case usOrg = "UsOrg"
        case planRab = "PlanRab"
        case accident
        case fkAddress = "fk_address"
    }
}

// MARK: - Accident
struct Accident: Codable {
    let id: Int
}

// MARK: - FkAddress
struct FkAddress: Codable {
    let text: String
}

// MARK: - Info
struct Info: Codable {
    let id: Int
    let icon, iconImageHref: String
    let iconImageOffset, iconImageSize: [Int]
    let count, planed: Int
    let preset, title: String
}

// MARK: - Mark
struct Mark: Codable {
    let type: String
    let geometry: Geometry
    let properties: Properties
    let id: Int
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

// MARK: - Properties
struct Properties: Codable {
    let address: String
    let accident: Accident
    let listCard: Int

    enum CodingKeys: String, CodingKey {
        case address, accident
        case listCard = "list_card"
    }
}
