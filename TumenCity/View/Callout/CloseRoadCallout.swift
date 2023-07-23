//
//  CloseRoadCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit

final class CloseRoadCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, calloutDescription, calloutDate])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleView: CalloutIconWithTitleView = {
        return CalloutIconWithTitleView()
    }()
    
    lazy var calloutDescription: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    lazy var calloutDate: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(stackViewContent)
        alertBackground.layer.borderColor = UIColor.red.cgColor
        
        setConstraints()
    }
    
    func configure(annotation: MKCloseRoadAnnotation) {
        titleView.setTitle(with: annotation.title, icon: annotation.icon ?? .add)
        
        calloutDescription.setLabelWithDescription(Strings.CloseRoadModule.CloseRoadCallout.description,
                                                   label: annotation.itemDescription)
        calloutDate.setLabelWithDescription(Strings.CloseRoadModule.CloseRoadCallout.datePeriod,
                                            label: annotation.dateEnd)
    }
    
}

extension CloseRoadCallout {
    
    func setConstraints() {
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
