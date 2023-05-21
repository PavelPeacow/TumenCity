//
//  CheckBoxWithTitle.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class CheckBoxWithTitle: UIView {
    
    lazy var contentStacKView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkBox, checkBoxTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var checkBox: CheckBoxButton = {
        let checkBox = CheckBoxButton()
        return checkBox
    }()
    
    lazy var checkBoxTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        checkBoxTitle.text = title
        
        addSubview(contentStacKView)
        
        contentStacKView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkBox.snp.makeConstraints {
            $0.size.equalTo(25)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
