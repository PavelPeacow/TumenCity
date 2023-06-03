//
//  UrbanImprovementsDetailInfo.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import Foundation

// MARK: - UrbanImprovements
struct UrbanImprovementsDetailInfo: Codable {
    let fields: UrbanImprovementsDetailInfoFields
}

// MARK: - Fields
struct UrbanImprovementsDetailInfoFields: Codable {
    let title: String?
    let category: [StageWork]?
    let stageWork: StageWork?
    let dateStart, vidWork: String?
    let img: [UrbanImprovementsImg]?

    enum CodingKeys: String, CodingKey {
        case title, img, category
        case stageWork = "stage_work"
        case dateStart = "date_start"
        case vidWork = "vid_work"
    }
}

struct UrbanImprovementsImg: Codable {
    let url: String
}

// MARK: - StageWork
struct StageWork: Codable {
    let id: Int
    let value: String
}
