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
        image.image = UIImage(systemName: "house")?.withTintColor(.black, renderingMode: .alwaysOriginal)
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
        label.font = .systemFont(ofSize: 24, weight: .regular)
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
        mainMenuTitle.text = menuTitle
        self.type = type
    }
    
}

extension MenuCollectionViewCell {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            menuStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            menuStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            menuStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            menuStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            menuStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            mainMenuIcon.heightAnchor.constraint(equalToConstant: 30),
            mainMenuIcon.widthAnchor.constraint(equalToConstant: 30),
            
            separator.heightAnchor.constraint(equalTo: mainMenuTitle.heightAnchor, multiplier: 1),
            separator.widthAnchor.constraint(equalToConstant: 1),
        ])
    }
    
}
