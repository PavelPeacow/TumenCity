//
//  CheckBoxButton.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class CheckBoxButton: UIButton {
    
    var checkedImage = UIImage(systemName: "checkmark")
    
    var isChecked = false {
        didSet {
            setState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.systemGray6.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setState() {
        let image = isChecked ? checkedImage : nil
        setImage(image, for: .normal)
    }
}
