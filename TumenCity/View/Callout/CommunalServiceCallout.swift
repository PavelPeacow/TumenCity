//
//  CommunalServiceCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit

final class CommunalServiceCallout: Callout {
    
    lazy var accidentCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [address, organization, dateStart, dateFinish])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var address: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var accident: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    lazy var organization: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    lazy var dateStart: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    lazy var dateFinish: CalloutLabelView = {
        return CalloutLabelView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        contentView.addSubview(stackView)
        
        setConstraints()
    }
    
    func configure(annotations: [MKItemAnnotation]) {
        guard let annotation = annotations.first else { return }
        
        address.text = "\(Strings.CommunalServicesModule.CommunalServiceCallout.adress) \(annotation.markDescription.address)"
        
        organization.setLabelWithDescription(Strings.CommunalServicesModule.CommunalServiceCallout.organization,
                                             label: annotation.orgTitle)
        dateStart.setLabelWithDescription(Strings.CommunalServicesModule.CommunalServiceCallout.dateStart,
                                          label: annotation.dateStart)
        dateFinish.setLabelWithDescription(Strings.CommunalServicesModule.CommunalServiceCallout.dateFinish,
                                           label: annotation.dateFinish)
        
        let colors = annotations.uniques(by: \.color).map { $0.color }
        
        for annotation in annotations.sorted(by: { $0.index > $1.index }) {
            
            let image = annotation.image
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.text = annotation.markDescription.accident
            
            let stackView = UIStackView(arrangedSubviews: [imageView, label])
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.snp.makeConstraints {
                $0.size.equalTo(25)
            }
            
            self.stackView.insertArrangedSubview(stackView, at: 1)
            
        }
        
        view.layoutSubviews()
        
        if annotations.count == 1 {
            alertBackground.layer.borderColor = annotation.color.cgColor
        } else {
            alertBackground.addGradientBorder(bounds: alertBackground.bounds, colors: colors)
        }
    }
}

extension CommunalServiceCallout {
    
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
    }
    
}
