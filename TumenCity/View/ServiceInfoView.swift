//
//  ServiceInfoView.swift
//  TumenCity
//
//  Created by Павел Кай on 18.02.2023.
//

import UIKit

protocol ServiceInfoViewDelegate {
    func didTapServiceInfoView(_ serviceType: Int, _ view: ServiceInfoView)
}

fileprivate enum ServiceInfoBackgroundColor {
    case whenTappedState
    case regularState
    
    var color: UIColor {
        switch self {
        case .whenTappedState:
            return .systemBlue
        case .regularState:
            return .systemGray6
        }
    }
}

final class ServiceInfoView: UIView {
    
    var delegate: ServiceInfoViewDelegate?
    
    var serviceType = 0
    
    var isTapAlready = false {
        didSet {
            if isTapAlready {
                backgroundColor = ServiceInfoBackgroundColor.whenTappedState.color
            } else {
                backgroundColor = ServiceInfoBackgroundColor.regularState.color
            }
        }
    }
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [serviceInfoIcon, serviceInfoTitle])
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }() 
    
    private lazy var serviceInfoIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var serviceInfoTitle: UILabel = {
        let label = UILabel()
        return label
    }()
    
    init(icon: UIImage, title: String, count: String, serviceType: Int) {
        super.init(frame: .zero)
        serviceInfoIcon.image = icon
        serviceInfoTitle.text = "\(title): \(count)"
        self.serviceType = serviceType

        addSubview(contentStackView)
        
        setUpView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 5
        clipsToBounds = true
        backgroundColor = ServiceInfoBackgroundColor.regularState.color
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapInfoView))
        addGestureRecognizer(gesture)
    }
    
}

extension ServiceInfoView {
    
    @objc func didTapInfoView() {
        delegate?.didTapServiceInfoView(serviceType, self)
    }
    
}

extension ServiceInfoView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            
            serviceInfoIcon.heightAnchor.constraint(equalToConstant: 30),
            serviceInfoIcon.widthAnchor.constraint(equalToConstant: 30),
        ])
    }
    
}
