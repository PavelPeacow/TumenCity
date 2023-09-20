//
//  UINavigationController+Appearence.swift
//  TumenCity
//
//  Created by Павел Кай on 20.09.2023.
//

import UIKit

extension UINavigationController {
    func setClearAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.backgroundEffect = nil
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    func setStandartAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .systemBackground
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}
