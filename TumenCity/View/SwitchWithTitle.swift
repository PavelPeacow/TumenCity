//
//  SwitchWithTitle.swift
//  TumenCity
//
//  Created by Павел Кай on 14.07.2023.
//

import UIKit

class SwitchWithTitle: UIView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [switcher, switchTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()
    
    lazy var switchTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    init(switchTitle: String, isOn: Bool = false, onTintColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        super.init(frame: .zero)
        addSubview(contentStackView)
        
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 15
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
        
        self.switchTitle.text = switchTitle
        self.switcher.isOn = isOn
        self.switcher.onTintColor = onTintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
