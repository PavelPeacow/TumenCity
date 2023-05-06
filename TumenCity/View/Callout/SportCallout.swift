//
//  SportCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit

final class SportCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle, stackViewContacts, stackViewAddresses])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutIcon, calloutTitle])
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var calloutIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var calloutTitle: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackViewContacts: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutContacts])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var calloutContacts: UILabel = {
        let label = UILabel()
        label.text = "Контакты:"
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var calloutEmail: UILabel = {
        let label = UILabel()
        label.text = "Электронная почта:"
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var stackViewAddresses: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutAddresses])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var calloutAddresses: UILabel = {
        let label = UILabel()
        label.text = "Адреса:"
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackViewContent)
        alertBackground.layer.borderColor = UIColor.green.cgColor
        
        setConstraints()
    }
    
    func configure(annotation: MKSportAnnotation) {
        
        calloutTitle.text = annotation.title
        calloutIcon.image = UIImage(named: "sportIcon") ?? .add

        annotation.contacts.phones.forEach { contact in
            let positionLabel = UILabel()
            positionLabel.numberOfLines = 0
            positionLabel.text = contact.position
            
            let nameLabel = UILabel()
            nameLabel.numberOfLines = 0
            nameLabel.text = contact.caption
            
            let numberLabel = UILabel()
            numberLabel.numberOfLines = 0
            numberLabel.text = contact.formated
            
            stackViewContacts.addArrangedSubview(positionLabel)
            stackViewContacts.addArrangedSubview(nameLabel)
            stackViewContacts.addArrangedSubview(numberLabel)
        }
        
        annotation.addresses.forEach { address in
            let addressLabel = UILabel()
            addressLabel.numberOfLines = 0
            addressLabel.text = address.title
            
            stackViewAddresses.addArrangedSubview(addressLabel)
        }
        
    }
    
}

extension SportCallout {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            alertBackground.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            alertBackground.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            alertBackground.topAnchor.constraint(equalTo: stackViewContent.topAnchor, constant: -15),
            alertBackground.bottomAnchor.constraint(equalTo: stackViewContent.bottomAnchor, constant: 15),
            alertBackground.widthAnchor.constraint(equalToConstant: 280),
            
            stackViewContent.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackViewContent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackViewContent.leadingAnchor.constraint(equalTo: alertBackground.leadingAnchor, constant: 15),
            stackViewContent.trailingAnchor.constraint(equalTo: alertBackground.trailingAnchor, constant: -15),
        ])
    }
    
}
