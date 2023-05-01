//
//  SHA256Encrypt.swift
//  TumenCity
//
//  Created by Павел Кай on 01.05.2023.
//

import Foundation
import CryptoKit

func sha256(string: String) -> String {
    let inputData = Data(string.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
    return hashString
}
