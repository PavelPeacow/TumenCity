//
//  SportViewMap.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit
import YandexMapsMobile

class SportViewMap: UIView {
    
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
        
        addSubview(map)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

extension SportViewMap {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            map.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
}
