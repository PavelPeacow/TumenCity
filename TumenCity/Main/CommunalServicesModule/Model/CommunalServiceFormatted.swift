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
    var accidentID: MarkType
    var address: String
    var coordinates: Coordinates
}

enum MarkType: Int {
    case cold = 1
    case hot = 2
    case otop = 4
    case electro = 5
    case gaz = 6
    case none = 7
}

struct Coordinates {
    var latitude: Double
    var lontitude: Double
}
