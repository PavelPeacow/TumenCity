//
//  TradeObjectCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class TradeObjectCallout: Callout {
    
    lazy var mainContentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, contentStackView, contentParemetresStackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleView: CalloutIconWithTitleView = {
        return CalloutIconWithTitleView()
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
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
        label.text = L10n.TradeObjects.Callout.parametersTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(mainContentStackView)
        
        setConstaints()
    }
    
    func configure(tradeObject: TradeObjectRow, image: UIImage, type: MKTradeObjectAnnotation.AnnotationType) {
        titleView.setTitle(with: tradeObject.fields.address ?? "", icon: image)
        
        switch type {
        case .activeTrade:
            alertBackground.layer.borderColor = UIColor.green.cgColor
        case .freeTrade:
            alertBackground.layer.borderColor = UIColor.blue.cgColor
        }
        
        [
            (tradeObject.fields.urName, L10n.TradeObjects.Callout.urName),
            (tradeObject.fields.numDoc, L10n.TradeObjects.Callout.numDoc),
            (tradeObject.fields.date, L10n.TradeObjects.Callout.dateDoc),
            (tradeObject.fields.okr, L10n.TradeObjects.Callout.area),
            (tradeObject.fields.object, L10n.TradeObjects.Callout.typeObject),
            (tradeObject.fields.spurpose, L10n.TradeObjects.Callout.purpose),
            (tradeObject.fields.period, L10n.TradeObjects.Callout.period)
        ].forEach { (text, description) in
            createCalloutLabelView( description: description, text: text)
        }
        
        [
            (tradeObject.fields.area, L10n.TradeObjects.Callout.areaSquare),
            (tradeObject.fields.floors, L10n.TradeObjects.Callout.floors),
            (tradeObject.fields.height, L10n.TradeObjects.Callout.height)
        ].forEach { (text, description) in
            createCalloutLabelView(description: description, text: text, isParameterForStackView: true)
        }
    }
    
    private func createCalloutLabelView(description: String, text: String?, isParameterForStackView: Bool = false) {
        guard let text else { return }
        let calloutLabelView = CalloutLabelView()
        calloutLabelView.setLabelWithDescription(description, label: text)
        if isParameterForStackView {
            contentParemetresStackView.addArrangedSubview(calloutLabelView)
        } else {
            contentStackView.addArrangedSubview(calloutLabelView)
        }
    }
    
    #warning("propably leave it, for future text design")
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
        mainContentStackView.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
