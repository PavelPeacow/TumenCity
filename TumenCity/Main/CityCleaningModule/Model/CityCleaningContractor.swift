//
//  CityCleaningContractor.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import Foundation

// MARK: - CityCleaningContractorElement
struct CityCleaningContractorElement: Codable {
    let council: String
    let contractor: [Contractor]
}

// MARK: - Contractor
struct Contractor: Codable {
    let id: Int
    let contractor: String
}
