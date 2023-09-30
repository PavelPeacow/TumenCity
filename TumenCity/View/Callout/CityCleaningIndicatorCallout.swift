//
//  CityCleaningIndicatorCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 23.07.2023.
//

import UIKit

final class CityCleaningIndicatorCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(stackViewContent)
        setConstaints()
    }
    
    func configureItem(model: CityCleaningIndicatorItem) {
        let dayNight = "\(model.sumMorning) | \(model.sumNight)"
        [(model.council, L10n.CityCleaning.Indicator.Callout.council),
         (String(model.countContractor), L10n.CityCleaning.Indicator.Callout.countContractor),
         (String(model.activeDuringDay), L10n.CityCleaning.Indicator.Callout.activeDuringDay),
         (dayNight, L10n.CityCleaning.Indicator.Callout.dayNight),
         (String(model.timelinessData), L10n.CityCleaning.Indicator.Callout.timelinessData),
        ].forEach { (label, description) in
            let labelView = CalloutLabelView()
            labelView.setLabelWithDescription(description, label: label)
            stackViewContent.addArrangedSubview(labelView)
        }
    }
    
    func configureSubitem(model: Detal) {
        let dayNight = "\(model.morningActivity ?? 0) | \(model.nightActivity ?? 0)"
        [(model.contractor, L10n.CityCleaning.Indicator.Callout.contractor),
         (String(model.countContractor), L10n.CityCleaning.Indicator.Callout.countContractor),
         (String(model.activeDuringDay), L10n.CityCleaning.Indicator.Callout.activeDuringDay),
         (dayNight, L10n.CityCleaning.Indicator.Callout.dayNight),
         (String(model.timelinessData), L10n.CityCleaning.Indicator.Callout.timelinessData),
        ].forEach { (label, description) in
            let labelView = CalloutLabelView()
            labelView.setLabelWithDescription(description, label: label)
            stackViewContent.addArrangedSubview(labelView)
        }
    }
}

extension CityCleaningIndicatorCallout {
    
    func setConstaints() {
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
