//
//  ClusterCalloutView.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit
import MapKit

class ClusterCalloutView: UIView {

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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    lazy var accident: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var organization: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var dateStart: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var dateFinish: UILabel = {
        let label = UILabel()
        return label
    }()
    
    init(cluster: MKClusterAnnotation) {
        super.init(frame: .zero)
        
        addSubview(stackView)
        configure(cluster: cluster)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(cluster: MKClusterAnnotation) {
        guard let clusterMember = cluster.memberAnnotations as? [MKItemAnnotation] else { return }
        address.text = clusterMember.first?.markDescription.address
        accident.text = clusterMember.first?.markDescription.accident
        organization.text = clusterMember.first?.orgTitle
        dateStart.text = clusterMember.first?.dateStart
        dateFinish.text = clusterMember.first?.dateFinish
        
        for annotation in clusterMember {
            
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
    
}

extension ClusterCalloutView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
}
