//
//  CityCleaningContractorsHeader.swift
//  TumenCity
//
//  Created by Павел Кай on 14.07.2023.
//

import UIKit

final class CityCleaningContractorsHeader: UICollectionReusableView {
    
    static let identifier = "CityCleaningContractorsHeader"
    
    lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contractorGroupTitle, bottomLine])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var contractorGroupTitle: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(15)
        }
        
        bottomLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        contractorGroupTitle.text = title
    }
    
}
