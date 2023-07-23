//
//  SportCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import SnapKit

final class SportCallout: Callout {
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleView, stackViewContacts, stackViewEmail, stackViewAddresses])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleView: CalloutIconWithTitleView = {
        return CalloutIconWithTitleView()
    }()
    
    lazy var stackViewContacts: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutContacts, contactDivider])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var contactDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    lazy var calloutContacts: UILabel = {
        let label = UILabel()
        label.text = Strings.SportModule.SportCallout.contacts
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var stackViewEmail: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutEmail, emailDivider])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var calloutEmail: UILabel = {
        let label = UILabel()
        label.text = Strings.SportModule.SportCallout.email
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    lazy var emailDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    lazy var stackViewAddresses: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutAddresses, addressesDivider])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var addressesDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    lazy var calloutAddresses: UILabel = {
        let label = UILabel()
        label.text = Strings.SportModule.SportCallout.addresses
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(stackViewContent)
        
        alertBackground.layer.borderColor = UIColor.green.cgColor
        
        setConstraints()
    }
    
    func configure(annotation: MKSportAnnotation) {
        titleView.setTitle(with: annotation.title, icon: UIImage(named: "sportIcon") ?? .add)

        annotation.contacts.phones.forEach { contact in
           
            //Validation for empty contacts
            if contact.caption.isEmpty && contact.position.isEmpty && contact.formated.isEmpty {
               return
            } else {
                let contactView = SportContactView(position: contact.position, name: contact.caption, number: contact.formated)
                stackViewContacts.addArrangedSubview(contactView)
            }

        }
        
        if let email = annotation.contacts.emails?.first {
            let emailLabel = CalloutLabelView(label: email.email)
            stackViewEmail.addArrangedSubview(emailLabel)
        }
    
        annotation.addresses.forEach { address in
            let addressLabel = CalloutLabelView(label: address.title)
            stackViewAddresses.addArrangedSubview(addressLabel)
        }
        
    }
    
}

extension SportCallout {
    
    func setConstraints() {   
        stackViewContent.snp.makeConstraints {
            $0.top.equalTo(contentView).inset(15)
            $0.horizontalEdges.equalTo(alertBackground).inset(15)
            $0.bottom.equalTo(contentView).inset(15)
        }
        
        contactDivider.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        addressesDivider.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        emailDivider.snp.makeConstraints {
            $0.height.equalTo(1)
        }
    }
    
}
