//
//  MainButton.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class MainButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        setTitle(title, for: .normal)
        setTitleColor(.label, for: .normal)
    }
    
    convenience init(title: String, cornerRadius: CGFloat) {
        self.init(title: title)
        layer.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
