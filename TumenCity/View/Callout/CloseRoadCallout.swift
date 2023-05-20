//
//  CloseRoadCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit

final class CloseRoadCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle, calloutDescription, calloutDate])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutIcon, calloutTitle])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var calloutIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var calloutTitle: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var calloutDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var calloutDate: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackViewContent)
        alertBackground.layer.borderColor = UIColor.red.cgColor
        
        setConstraints()
    }
    
    func configure(annotation: MKCloseRoadAnnotation) {
        calloutIcon.image = annotation.icon ?? .add
        calloutTitle.text = annotation.title
        
        calloutDescription.text = "Описание:\n\(annotation.itemDescription)"
        calloutDate.text = "Период:\nc \(annotation.dateStart) по \(annotation.dateEnd)"
    }
    
}

extension CloseRoadCallout {
    
    func setConstraints() {
        alertBackground.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.top.bottom.equalTo(stackViewContent).inset(-15)
        }
        
        stackViewContent.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalTo(alertBackground).inset(15)
        }
        
    }
    
}
