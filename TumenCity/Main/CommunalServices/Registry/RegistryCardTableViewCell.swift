//
//  RegistryCardTableViewCell.swift
//  TumenCity
//
//  Created by Павел Кай on 22.02.2023.
//

import UIKit

final class RegistryCardTableViewCell: UITableViewCell {
    
    static let identifier = "RegistryCardTableViewCell"
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackViewAccidentIcon: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewMainInformation: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardID, accidentTitle, orgTitle, time])
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var cardID: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var accidentTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var orgTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var time: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
       
        contentView.addSubview(containerView)
        containerView.addSubview(separator)
        containerView.addSubview(stackViewAccidentIcon)
        containerView.addSubview(stackViewMainInformation)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(communalService: CommunalServicesFormatted) {
        cardID.text = "# \(communalService.cardID)"
        accidentTitle.text = "Причина: \(communalService.workType)"
        orgTitle.text = "Устраняющая организация: \(communalService.orgTitle)"
        time.text = "с \(communalService.dateStart) по \(communalService.dateFinish)"
        
        let accidentsID = Set(communalService.mark.map { $0.accidentID })

        stackViewAccidentIcon.arrangedSubviews.forEach {
            stackViewAccidentIcon.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for id in accidentsID {
            print(communalService.cardID)
            print(id)
            let icon = UIImage(named: "filter-\(id)")
            let iconView = UIImageView(image: icon)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            
            stackViewAccidentIcon.addArrangedSubview(iconView)
        }
    }
    
}

extension RegistryCardTableViewCell {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25),
            
            separator.leadingAnchor.constraint(equalTo: stackViewAccidentIcon.trailingAnchor, constant: 5),
            separator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            separator.widthAnchor.constraint(equalToConstant: 1),
            
            stackViewAccidentIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            stackViewAccidentIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            stackViewAccidentIcon.widthAnchor.constraint(equalToConstant: 30),
            
            stackViewMainInformation.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            stackViewMainInformation.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 5),
            stackViewMainInformation.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            stackViewMainInformation.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
        ])
    }
}
