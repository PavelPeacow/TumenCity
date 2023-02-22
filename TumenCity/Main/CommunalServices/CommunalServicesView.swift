//
//  MainMapView.swift
//  TumenCity
//
//  Created by Павел Кай on 18.02.2023.
//

import UIKit
import MapKit

final class CommunalServicesView: UIView {
    
    lazy var servicesInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.register(MKItemAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKItemAnnotationView.identifier)
        map.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.identifier)
        return map
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addSubview(servicesInfoStackView)
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
            servicesInfoStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            servicesInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            servicesInfoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            
            map.topAnchor.constraint(equalTo: servicesInfoStackView.bottomAnchor, constant: 10),
            map.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
}
