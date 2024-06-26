//
//  CityCleaningCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit

final class CityCleaningCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, itemUpdatedTime])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleView: CalloutIconWithTitleView = {
        return CalloutIconWithTitleView()
    }()
    
    lazy var itemUpdatedTime: CalloutLabelView = {
        let label = CalloutLabelView(label: "")
        label.calloutLabel.textColor = .systemGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(stackViewContent)
        setConstaints()
    }
    
    func configure(annotation: MKCityCleaningAnnotation) {
        titleView.setTitle(with: annotation.number ?? "", icon: annotation.icon ?? .add)
        itemUpdatedTime.setLabelWithDescription(L10n.CityCleaning.Callout.lastTimeUpdated, label: annotation.date)
        
        [(annotation.council, L10n.CityCleaning.Callout.council),
         (annotation.contractor, L10n.CityCleaning.Callout.contractor),
         (annotation.carType, L10n.CityCleaning.Callout.carType)].forEach { (text, description) in
            let label = CalloutLabelView()
            label.setLabelWithDescription(description, label: text)
            stackViewContent.addArrangedSubview(label)
        }
        
        if let speed = annotation.speed {
            let label = CalloutLabelView()
            label.setLabelWithDescription(L10n.CityCleaning.Callout.iAmSpeed, label: String(speed))
            stackViewContent.addArrangedSubview(label)
        }
    }
}

extension CityCleaningCallout {
    
    func setConstaints() {
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
