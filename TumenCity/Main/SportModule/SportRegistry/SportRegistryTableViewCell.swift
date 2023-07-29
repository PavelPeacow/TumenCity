//
//  SportRegistryTableViewCell.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit
import RxSwift

final class SportRegistryTableViewCell: UITableViewCell {
    
    static let identifier = "SportRegistryTableViewCell"
    
    var addresses = [Address]()
    
    private let selectedAddress = PublishSubject<Address>()
    var selectedAddressObservable: Observable<Address> {
        selectedAddress
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var sportIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sportIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var sportTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stackViewMainInformation: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sportTeleWithIcon, sportEmailWithIcon, sportAddresses])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var sportTeleWithIcon: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [teleIcon, sportTeleNumber])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var teleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "teleIcon")?.withTintColor(.label)
        return imageView
    }()
    
    lazy var sportTeleNumber: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var sportEmailWithIcon: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailIcon, sportEmail])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var emailIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emailIcon")?.withTintColor(.label)
        return imageView
    }()
    
    lazy var sportEmail: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var sportAddresses: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        contentView.addSubview(containerView)
        containerView.addSubview(separator)
        containerView.addSubview(sportIcon)
        containerView.addSubview(sportTitle)
        containerView.addSubview(stackViewMainInformation)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sportEmailWithIcon.isHidden = false
        
        sportAddresses.arrangedSubviews.forEach {
            sportAddresses.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func configure(sportElement: SportElement) {
        
        sportTitle.text = sportElement.title
        sportTeleNumber.text = sportElement.contacts.primary?.formated
        
        if let email = sportElement.contacts.emails?.first?.email {
            sportEmail.text = email
        } else {
            sportEmailWithIcon.isHidden = true
        }
        
        sportElement.addresses.forEach { address in
            let addressIcon = UIImageView()
            addressIcon.contentMode = .scaleAspectFit
            addressIcon.image = UIImage(named: "addressIcon")?.withTintColor(.label)
            
            let addressLabel = UILabel()
            addressLabel.text = address.title
            addressLabel.numberOfLines = 0
            addressLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddress))
            addressLabel.addGestureRecognizer(tapGesture)
            
            let stackView = UIStackView(arrangedSubviews: [addressIcon, addressLabel])
            stackView.axis = .horizontal
            stackView.spacing = 4
           
            sportAddresses.addArrangedSubview(stackView)
        }
        
        addresses = sportElement.addresses
    }
    
}

extension SportRegistryTableViewCell {
    
    @objc func didTapAddress(_ sender: UITapGestureRecognizer) {
        guard let addressTitle = (sender.view as? UILabel)?.text else { return }
        
        if let address = addresses.first(where: { $0.title == addressTitle }) {
            selectedAddress
                .onNext(address)
        }
    }
    
}

extension SportRegistryTableViewCell {
    
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(25)
        }
        
        sportTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.leading.equalTo(separator.snp.trailing).offset(5)
        }
        
        sportIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.leading.equalToSuperview().inset(5)
            $0.width.equalTo(30)
        }
        
        separator.snp.makeConstraints {
            $0.leading.equalTo(sportIcon.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(1)
        }
        
        stackViewMainInformation.snp.makeConstraints {
            $0.leading.equalTo(separator).offset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(5)
            $0.top.equalTo(sportTitle.snp.bottom).offset(5)
        }
    }
}
