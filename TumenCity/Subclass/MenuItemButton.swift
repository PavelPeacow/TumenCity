//
//  MenuItemButton.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit

enum MenuItemType: String {
    case sport = "Спорт"
    case cityCleaning = "Уборка города"
    case bikePaths = "Велодорожки"
    case urbanImprovements = "Благоустройство"
    case communalServices = "Отключение ЖКУ"
    case roadClose = "Перекрытие дорог"
    case digWork = "Земляные работы"
    case tradeObjects = "Нестационарные торговые объекты"
    case none
}

final class MenuItemButton: UIButton {
    
    var type: MenuItemType = .none
    
    init(menuIcon: UIImage, menuTitle: String) {
        super.init(frame: .zero)
        self.type = MenuItemType(rawValue: menuTitle) ?? .none
        
        setTitle(menuTitle, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.adjustsFontSizeToFitWidth = true
        setImage(menuIcon.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 15)
        
        setUpView()
        setConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        clipsToBounds = true
        setBlur()
    }

}

extension MenuItemButton {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}
