//
//  SportLabelView.swift
//  TumenCity
//
//  Created by Павел Кай on 07.05.2023.
//

import UIKit
import SnapKit

final class SportLabelView: UIView {
    
    lazy var sportLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(label: String) {
        super.init(frame: .zero)
        
        sportLabel.text = label
        
        addSubview(sportLabel)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 6
        
        sportLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
