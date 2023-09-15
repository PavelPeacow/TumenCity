//
//  Logger.swift
//  TumenCity
//
//  Created by Павел Кай on 06.09.2023.
//

import Foundation

enum LogLevel: String {
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
}

final class Logger {
    private init() { }
    
    static func log(_ level: LogLevel,
                    _ message: String,
                    file: String = #file, line: Int = #line, function: String = #function
    ) {
        let emoji = level.rawValue
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(emoji) [\(level)] [\(sourceFileName(filePath: file)):\(line)] \(function) - \(message)"
        print(logMessage)
    }
    
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
