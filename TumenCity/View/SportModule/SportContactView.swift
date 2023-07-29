//
//  SportContactView.swift
//  TumenCity
//
//  Created by Павел Кай on 07.05.2023.
//

import UIKit

final class SportContactView: UIView {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [positionLabel, nameLabel, numberLabel])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(position: String, name: String, number: String) {
        super.init(frame: .zero)
        
        positionLabel.text = position
        nameLabel.text = name
        numberLabel.text = number
        
        checkForEmptyFields()
        
        addSubview(stackViewContent)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 6
        
        stackViewContent.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkForEmptyFields() {
        if let posText = positionLabel.text, posText.isEmpty {
            positionLabel.isHidden = true
        }
        
        if let nameText = nameLabel.text, nameText.isEmpty {
            nameLabel.isHidden = true
        }
        
        if let numText = numberLabel.text, numText.isEmpty {
            numberLabel.isHidden = true
        }
    }
        
}
