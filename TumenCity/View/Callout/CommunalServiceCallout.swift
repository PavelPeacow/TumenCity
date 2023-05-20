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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    lazy var accident: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var organization: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateStart: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateFinish: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.addSubview(stackView)
        alertBackground.addSubview(stackView)
        
        setConstraints()
    }
    
    func configure(annotations: [MKItemAnnotation]) {
        guard let annotation = annotations.first else { return }
        
        address.text = "Адрес: \(annotation.markDescription.address)"
        organization.text = "Устраняющая организация:\n\(annotation.orgTitle)"
        dateStart.text = "Дата начала работ:\n\(annotation.dateStart)"
        dateFinish.text = "Дата окончания работ:\n\(annotation.dateFinish)"
        
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
        alertBackground.snp.makeConstraints {
            $0.top.bottom.equalTo(stackView).inset(-15)
            $0.width.equalTo(280)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.leading.trailing.equalTo(alertBackground).inset(15)
        }
    }
    
}
