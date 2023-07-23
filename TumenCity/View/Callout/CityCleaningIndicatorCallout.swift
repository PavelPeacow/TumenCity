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
        [(model.council, "Заказчик: "),
        (String(model.countContractor), "Всего техники: "),
        (String(model.activeDuringDay), "Передавали данные о местоположении техники за последние 3 суток: "),
        (dayNight, "Данные о местоположении техники\nдень | ночь: "),
        (String(model.timelinessData), "Своевременность передачи данных: "),
        ].forEach { (label, description) in
            let labelView = CalloutLabelView()
            labelView.setLabelWithDescription(description, label: label)
            stackViewContent.addArrangedSubview(labelView)
        }
    }
    
    func configureSubitem(model: Detal) {
        let dayNight = "\(model.morningActivity ?? 0) | \(model.nightActivity ?? 0)"
        [(model.contractor, "Подрядчик"),
        (String(model.countContractor), "Всего техники: "),
        (String(model.activeDuringDay), "Передавали данные о местоположении техники за последние 3 суток: "),
        (dayNight, "Данные о местоположении техники\nдень | ночь: "),
        (String(model.timelinessData), "Своевременность передачи данных: "),
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
