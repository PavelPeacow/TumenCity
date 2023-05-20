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
    
    lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    
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
        servicesInfoStackViewWithTitle.snp.makeConstraints {
            $0.topMargin.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(5)
        }
        
        YandexMapMaker.setYandexMapLayout(map: map, in: self) { [weak self] in
            guard let self else { return }
            $0.top.equalTo(self.servicesInfoStackViewWithTitle.snp.bottom).offset(5)
        }
    }
    
}
