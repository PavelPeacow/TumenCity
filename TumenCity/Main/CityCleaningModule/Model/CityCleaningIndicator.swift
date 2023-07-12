//
//  CityCleaningIndicator.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import Foundation

// MARK: - CityCleaningIndicator
struct CityCleaningIndicator: Codable {
    let all: All
    let ao: [Ao]
}

// MARK: - All
struct All: Codable {
    let activeDuringDay, countContractor, timelinessData, timelinessDataCount: Int
    let sumMorning, sumNight: Int

    enum CodingKeys: String, CodingKey {
        case activeDuringDay = "active_during_day"
        case countContractor = "count_contractor"
        case timelinessData = "timeliness_data"
        case timelinessDataCount = "timeliness_data_count"
        case sumMorning = "sum_morning"
        case sumNight = "sum_night"
    }
}

// MARK: - Ao
struct Ao: Codable {
    let idCouncil: Int
    let council: String
    let timelinessData, activeDuringDay, countContractor, sumMorning: Int
    let sumNight: Int
    let detal: [Detal]

    enum CodingKeys: String, CodingKey {
        case idCouncil = "id_council"
        case council
        case timelinessData = "timeliness_data"
        case activeDuringDay = "active_during_day"
        case countContractor = "count_contractor"
        case sumMorning = "sum_morning"
        case sumNight = "sum_night"
        case detal
    }
}

// MARK: - Detal
struct Detal: Codable {
    let contractor: String
    let countContractor: Int
    let activeDuringDay, timelinessData: Int
    let seeReport: Bool
    let morningActivity, nightActivity: Int?

    enum CodingKeys: String, CodingKey {
        case contractor
        case countContractor = "count_contractor"
        case activeDuringDay = "active_during_day"
        case timelinessData = "timeliness_data"
        case seeReport = "see_report"
        case morningActivity = "morning_activity"
        case nightActivity = "night_activity"
    }
}
