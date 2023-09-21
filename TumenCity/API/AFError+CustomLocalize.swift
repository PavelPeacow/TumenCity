//
//  AFError+CustomLocalize.swift
//  TumenCity
//
//  Created by Павел Кай on 21.09.2023.
//

import Alamofire

extension AFError {
    var localizedDescription: String {
        switch self {
        case .sessionTaskFailed:
            "Ошибка! Проверьте интернет соединение"
        default:
            "Ошибка! Что-то пошло не так, повторите попытку позже"
        }
    }
}
