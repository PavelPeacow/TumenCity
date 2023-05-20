//
//  TradeObjectCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class TradeObjectCallout: Callout {
    
    lazy var mainContentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, contentStackView, contentParemetresStackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tradeObjectIcon, titleLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var tradeObjectIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tradeObjectIcon, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var contentParemetresStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [parametersLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var parametersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.text = Strings.TradeObjectsModule.parametersTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBackground.addSubview(mainContentStackView)
        
        setConstaints()
    }
    
    func configure(tradeObject: TradeObjectRow, image: UIImage, type: MKTradeObjectAnnotation.AnnotationType) {
        tradeObjectIcon.image = image
        titleLabel.text = tradeObject.fields.address
        
        switch type {
        case .activeTrade:
            alertBackground.layer.borderColor = UIColor.green.cgColor
        case .freeTrade:
            alertBackground.layer.borderColor = UIColor.blue.cgColor
        }
        
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.urName, text: tradeObject.fields.urName)
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.numDoc, text: tradeObject.fields.numDoc)
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.dateDoc, text: tradeObject.fields.date)
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.area, text: tradeObject.fields.okr)
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.purpose, text: tradeObject.fields.object)
        createDescriptionLabel(descriptionText: Strings.TradeObjectsModule.period, text: tradeObject.fields.spurpose)
        
        createParameterLabel(descriptionText: Strings.TradeObjectsModule.areaSquare, text: tradeObject.fields.area)
        createParameterLabel(descriptionText: Strings.TradeObjectsModule.floors, text: tradeObject.fields.floors)
        createParameterLabel(descriptionText: Strings.TradeObjectsModule.height, text: tradeObject.fields.height)
    }
    
    private func createDescriptionLabel(descriptionText: String, text: String?) {
        guard let text else { return }
        guard let atrString = addAttrString(string: descriptionText + text) else { return }
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = atrString
        contentStackView.addArrangedSubview(label)
    }
    
    private func createParameterLabel(descriptionText: String, text: String?) {
        guard let text else { return }
        guard let atrString = addAttrString(string: descriptionText + text) else { return }
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = atrString
        contentParemetresStackView.addArrangedSubview(label)
    }
    
    private func addAttrString(string: String) -> NSMutableAttributedString? {
        if let colonRange = string.range(of: ":") {
            let startIndex = string.distance(from: string.startIndex, to: colonRange.lowerBound) + 1
            let atrString = NSMutableAttributedString(string: string)
            atrString.addAttribute(.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: startIndex))
            return atrString
        }
        return nil
    }

}

extension TradeObjectCallout {
    
    func setConstaints() {
        alertBackground.snp.makeConstraints {
            $0.topMargin.greaterThanOrEqualToSuperview().inset(10)
            $0.bottomMargin.lessThanOrEqualToSuperview().inset(10)
            $0.width.equalToSuperview().inset(25)
            $0.center.equalToSuperview()
        }
        
        mainContentStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(15)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
