//
//  SportCallout.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import SnapKit

final class SportCallout: Callout {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.flashScrollIndicators()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackViewContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stackViewTitle, stackViewContacts, stackViewEmail, stackViewAddresses])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewTitle: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calloutIcon, calloutTitle])
        stackView.distribution = .fill
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
        label.text = "Контакты:"
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
        label.text = "Электронная почта:"
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
        label.text = "Адреса:"
        label.font = . systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBackground.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackViewContent)
        
        alertBackground.layer.borderColor = UIColor.green.cgColor
        
        setConstraints()
    }
    
    func configure(annotation: MKSportAnnotation) {
        calloutTitle.text = annotation.title
        calloutIcon.image = UIImage(named: "sportIcon") ?? .add
        
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
            let emailLabel = SportLabelView(label: email.email)
            stackViewEmail.addArrangedSubview(emailLabel)
        }
    
        annotation.addresses.forEach { address in
            let addressLabel = SportLabelView(label: address.title)
            stackViewAddresses.addArrangedSubview(addressLabel)
        }
        
    }
    
}

extension SportCallout {
    
    func setConstraints() {
        alertBackground.snp.makeConstraints {
            $0.width.equalToSuperview().inset(25)
            $0.center.equalToSuperview()
            $0.topMargin.greaterThanOrEqualTo(view).inset(10)
            $0.bottomMargin.lessThanOrEqualTo(view).inset(10)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
            $0.width.equalToSuperview()
        }
        
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
