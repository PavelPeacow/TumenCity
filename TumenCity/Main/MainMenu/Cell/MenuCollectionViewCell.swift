//
//  MenuCollectionViewCell.swift
//  TumenCity
//
//  Created by Павел Кай on 21.02.2023.
//

import UIKit

final class MenuCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MenuTableViewCell"
    
    var type: MenuItemType = .none
    
    lazy var menuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainMenuIcon, separator, mainMenuTitle])
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var mainMenuIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var mainMenuTitle: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(menuStackView)
        
        layer.cornerRadius = 15
        clipsToBounds = true
        
        setBlurView()
        setConstraints()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with menuIcon: UIImage, menuTitle: String, type: MenuItemType) {
        mainMenuIcon.image = menuIcon
        mainMenuTitle.text = menuTitle
        self.type = type
    }
    
}

extension MenuCollectionViewCell {
    
    func setConstraints() {
        menuStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        mainMenuIcon.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        separator.snp.makeConstraints {
            $0.height.equalTo(mainMenuTitle.snp.height).multipliedBy(1)
            $0.width.equalTo(1)
        }
    }
    
}
