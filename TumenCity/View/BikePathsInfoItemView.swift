//
//  BikePathsInfoItemView.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import UIKit
import SnapKit
import SDWebImage

final class BikePathsInfoItemView: UIView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bikePathInfoIcon, bikePathInfoDescription])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var bikePathInfoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var bikePathInfoDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 6
        addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
        
        bikePathInfoIcon.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(infoIcon: String, infoDescrtiption: String) {
        if let url = URL(string: infoIcon) {
            bikePathInfoIcon.sd_imageIndicator = SDWebImageActivityIndicator.gray
            bikePathInfoIcon.sd_setImage(with: url)
        }
        
        bikePathInfoDescription.text = infoDescrtiption
    }
    

}
