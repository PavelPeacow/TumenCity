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
        let atrString = NSMutableAttributedString(string: "# ")
        atrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: 1))
        label.attributedText = atrString
        return label
    }()
    
    lazy var accidentTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let atrString = NSMutableAttributedString(string: "Причина:\n" )
        atrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: atrString.length))
        label.attributedText = atrString
        return label
    }()
    
    lazy var orgTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let atrString = NSMutableAttributedString(string: "Устраняющая организация:\n")
        atrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: atrString.length))
        label.attributedText = atrString
        return label
    }()
    
    lazy var time: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let atrString = NSMutableAttributedString(string: "c")
        atrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: 1))
        label.attributedText = atrString
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetCellWhenReuse()
    }
    
    private func resetCellWhenReuse() {
        let cardIDString = NSMutableAttributedString(string: "# ")
        cardIDString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: 1))
        cardID.attributedText = cardIDString
        
        let accidentTitleString = NSMutableAttributedString(string: "Причина:\n" )
        accidentTitleString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: accidentTitleString.length))
        accidentTitle.attributedText = accidentTitleString
        
        let orgTitleString = NSMutableAttributedString(string: "Устраняющая организация:\n")
        orgTitleString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: orgTitleString.length))
        orgTitle.attributedText = orgTitleString
        
        let timeString = NSMutableAttributedString(string: "c")
        timeString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: 1))
        time.attributedText = timeString
        
        stackViewAccidentIcon.arrangedSubviews.forEach {
            stackViewAccidentIcon.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func configure(communalService: CommunalServicesFormatted) {
        let cardIDText = NSMutableAttributedString(attributedString: cardID.attributedText ?? .init(string: ""))
        cardIDText.append(NSAttributedString(string: "\(communalService.cardID)"))
        cardID.attributedText = cardIDText
        
        let accidentText = NSMutableAttributedString(attributedString: accidentTitle.attributedText ?? .init(string: ""))
        accidentText.append(NSAttributedString(string: "\(communalService.workType)"))
        accidentTitle.attributedText = accidentText
        
        let orgText = NSMutableAttributedString(attributedString: orgTitle.attributedText ?? .init(string: ""))
        orgText.append(NSAttributedString(string: "\(communalService.orgTitle)"))
        orgTitle.attributedText = orgText
        
        let timeText = NSMutableAttributedString(attributedString: time.attributedText ?? .init(string: ""))
        timeText.insert(NSAttributedString(string: " \(communalService.dateStart) "), at: 1)
        let finish = NSMutableAttributedString(string: "по \(communalService.dateFinish)")
        finish.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: 2))
        timeText.append(finish)
        time.attributedText = timeText
        
        let accidentsID = Set(communalService.mark.map { $0.accidentID }).sorted()

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
