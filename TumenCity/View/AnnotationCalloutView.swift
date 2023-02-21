//
//  AnnotationCalloutView.swift
//  TumenCity
//
//  Created by Павел Кай on 20.02.2023.
//

import UIKit
import MapKit

final class AnnotationCalloutView: UIView {
    
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
    
    init(annotation: MKItemAnnotation) {
        super.init(frame: .zero)
        
        addSubview(stackView)
        configure(annotation: annotation)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(annotation: MKItemAnnotation) {
        address.text = "Адрес: \(annotation.markDescription.address)"
        organization.text = "Устраняющая организация: \(annotation.orgTitle)"
        dateStart.text = "Дата начала работ: \(annotation.dateStart)"
        dateFinish.text = "Дата окончания работ: \(annotation.dateFinish)"
        
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
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 25),
        ])
        
        self.stackView.insertArrangedSubview(stackView, at: 1)
    }
}


extension AnnotationCalloutView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
}
