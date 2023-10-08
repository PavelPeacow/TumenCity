//
//  FilterView.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import UIKit

final class FilterView: UIView {
    
    var changeText: ((String) -> Void)?
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterLabel, textField])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        textField.addTarget(self, action: #selector(didCnangeText), for: .editingChanged)
        return textField
    }()
    
    init(filterLabel: String) {
        super.init(frame: .zero)
        
        self.filterLabel.text = filterLabel
        
        addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FilterView {
    @objc
    func didCnangeText(_ sender: UITextField) {
        changeText?(sender.text ?? "")
    }
}
