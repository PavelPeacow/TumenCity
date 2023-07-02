//
//  ServiceInfoView.swift
//  TumenCity
//
//  Created by Павел Кай on 18.02.2023.
//

import UIKit
import RxSwift

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
    typealias ServiceTappedTypealias = (serviceType: Int, view: ServiceInfoView)
    
    private let tappedServiceInfo = PublishSubject<ServiceTappedTypealias>()
    var tappedServiceInfoObservable: Observable<ServiceTappedTypealias> {
        tappedServiceInfo.asObservable()
    }
    
    var serviceType = 0
    
    var serviceTitle: String?
    
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
        serviceInfoTitle.text = "\(count)"
        serviceTitle = title
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
        tappedServiceInfo
            .onNext((serviceType, self))
    }
    
}

extension ServiceInfoView {
    
    func setConstraints() {
        contentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(3)
            $0.leading.trailing.equalToSuperview().inset(5)
        }
        
        serviceInfoIcon.snp.makeConstraints {
            $0.size.equalTo(30)
        }
    }
    
}
