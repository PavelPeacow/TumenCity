//
//  MenuHeaderCollectionReusableView.swift
//  TumenCity
//
//  Created by Павел Кай on 21.02.2023.
//

import UIKit

final class MenuHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "MenuHeaderCollectionReusableView"
    
    lazy var logoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainMenuLogo, mainMenuTitle])
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var mainMenuLogo: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var mainMenuTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .black)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Портал цифровых сервисов Тюмень"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoStackView)
        
        logoStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
