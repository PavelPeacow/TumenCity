//
//  ViewActionsInteractable.swift
//  TumenCity
//
//  Created by Павел Кай on 18.10.2023.
//

import Foundation

protocol ViewActionsInteractable {
    associatedtype T
    func action(_ action: T)
}
