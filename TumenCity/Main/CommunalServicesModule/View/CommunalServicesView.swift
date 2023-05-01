//
//  MainMapView.swift
//  TumenCity
//
//  Created by Павел Кай on 18.02.2023.
//

import UIKit
import YandexMapsMobile

final class CommunalServicesView: UIView {
    
    lazy var servicesInfoStackViewWithTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [servicesInfoStackView, infoTitle])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var servicesInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var infoTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.isHidden = true
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()
    
    lazy var map: YMKMapView = {
        let map = YMKMapView()
        map.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        map.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 20, verticalPadding: 50*2))
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addSubview(servicesInfoStackViewWithTitle)
        addSubview(map)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

extension CommunalServicesView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            servicesInfoStackViewWithTitle.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            servicesInfoStackViewWithTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            servicesInfoStackViewWithTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            map.topAnchor.constraint(equalTo: servicesInfoStackViewWithTitle.bottomAnchor, constant: 5),
            map.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
}
