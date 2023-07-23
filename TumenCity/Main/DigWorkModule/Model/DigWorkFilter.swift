//
//  DigWorkFilter.swift
//  TumenCity
//
//  Created by Павел Кай on 11.07.2023.
//

import Foundation

struct DigWorkFilter: Encodable {
    let person: String
    let zone: String
    let missionType: String
    let state: String
    let startWorkTime: String
    let endWorkTime: String
}
