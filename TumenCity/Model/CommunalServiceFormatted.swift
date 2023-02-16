//
//  CommunalServiceFormatted.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import Foundation

struct CommunalServicesFormatted {
    var cardID: Int
    var workType: String
    var dateStart: String
    var dateFinish: String
    var orgTitle: String
    var mark: [MarkDescription]
}

struct MarkDescription {
    var accident: String
    var accidentID: Int
    var address: String
    var coordinates: Coordinates
}

struct Coordinates {
    var latitude: Double
    var lontitude: Double
}
