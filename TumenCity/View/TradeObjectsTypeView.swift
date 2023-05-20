//
//  TradeObjectsTypeView.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

class TradeObjectsTypeView: UIView {
    
    var isTappedFilterView = false {
        willSet {
            if newValue {
                backgroundColor = .systemBlue
            } else {
                backgroundColor = .systemGray6
            }
        }
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tradeObjectIcon, filterTitleLabel, countLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var tradeObjectIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.snp.contentCompressionResistanceHorizontalPriority = 999
        return image
    }()
    
    lazy var filterTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.snp.contentCompressionResistanceHorizontalPriority = 999
        return label
    }()
    
    init(icon: UIImage, count: String, filterTitle: String) {
        super.init(frame: .zero)
        
        tradeObjectIcon.image = icon
        filterTitleLabel.text = filterTitle
        countLabel.text = count
        
        backgroundColor = .systemGray6
        
        layer.cornerRadius = 15
        
        addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapFilterView() {
        isTappedFilterView.toggle()
    }
    
}
