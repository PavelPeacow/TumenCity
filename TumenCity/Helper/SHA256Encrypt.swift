//
//  SHA256Encrypt.swift
//  TumenCity
//
//  Created by Павел Кай on 01.05.2023.
//

import Foundation
import CryptoKit

enum APIConstant {
    static let shaKey = "M0b!1e@pp!nf0!ntegr@t!0ne_crm2O23"
}

fileprivate func sha256(string: String) -> String {
    let inputData = Data(string.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
    return hashString
}

func createToken() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYYddMM"
    let dateString = dateFormatter.string(from: Date())
    return sha256(string: dateString + APIConstant.shaKey)
}
