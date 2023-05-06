//
//  Sport.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

// MARK: - SportElement
struct SportElement: Codable {
    let id: Int
    let url, title: String
    let addresses: [Address]
    let contacts: Contacts
}

// MARK: - Address
struct Address: Codable {
    let id: Int
    let title: String
    let latitude, longitude: Itude
    let numberPeople: Int

    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude
        case numberPeople = "number_people"
    }
}

enum Itude: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Itude.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Itude"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Contacts
struct Contacts: Codable {
    let phones: [Phone]
    let primary: Primary?
    let emails: [Email]?
    let socialNetworkLinks: [SocialNetworkLink]?

    enum CodingKeys: String, CodingKey {
        case phones, primary, emails
        case socialNetworkLinks = "social_network_links"
    }
}

// MARK: - Email
struct Email: Codable {
    let email: String
}

// MARK: - Phone
struct Phone: Codable {
    let number: Number
    let formated: String
    let caption, position: String
}

enum Number: Codable {
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
        throw DecodingError.typeMismatch(Number.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Number"))
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

// MARK: - Primary
struct Primary: Codable {
    let number: Number
    let formated: String
    let caption, position: String
}

// MARK: - SocialNetworkLink
struct SocialNetworkLink: Codable {
    let socialNetworkLink: String

    enum CodingKeys: String, CodingKey {
        case socialNetworkLink = "social_network_link"
    }
}
