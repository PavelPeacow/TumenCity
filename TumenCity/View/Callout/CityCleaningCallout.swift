//
//  CityCleaningCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit

final class CityCleaningCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle, itemUpdatedTime])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [itemIcon, itemTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var itemIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return image
    }()
    
    lazy var itemTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()
    
    lazy var itemUpdatedTime: CalloutLabelView = {
        let label = CalloutLabelView(label: "")
        label.sportLabel.textColor = .systemGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBackground.addSubview(stackViewContent)
        setConstaints()
    }
    
    func configure(annotation: MKCityCleaningAnnotation) {
        itemIcon.image = annotation.icon ?? .add
        itemTitle.text = annotation.number
        itemUpdatedTime.sportLabel.text = "Последнее обновление данных произошло в \(annotation.date)"
        
        configureSportLabel(with: annotation.council, description: "Управляющая организация: ")
        configureSportLabel(with: annotation.contractor, description: "Подрядчик: ")
        configureSportLabel(with: annotation.carType, description: "Тип ТС: ")
        if let speed = annotation.speed {
            configureSportLabel(with: String(speed), description: "Скорость: ")
        }
    }
    
    private func configureSportLabel(with text: String?, description: String) {
        if let text = text {
            let label = CalloutLabelView(label: description + text)
            stackViewContent.addArrangedSubview(label)
        }
    }
    
}

extension CityCleaningCallout {
    
    func setConstaints() {
        alertBackground.snp.makeConstraints {
            $0.topMargin.greaterThanOrEqualToSuperview().inset(10)
            $0.bottomMargin.lessThanOrEqualToSuperview().inset(10)
            $0.width.equalToSuperview().inset(10)
            $0.center.equalToSuperview()
        }
        
        stackViewContent.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
