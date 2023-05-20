//
//  RegistryCardTableViewCell.swift
//  TumenCity
//
//  Created by Павел Кай on 22.02.2023.
//

import UIKit

protocol RegistryCardTableViewCellDelegate {
    func updateTableWhenShowAddresses()
    func didTapAddress(_ mark: MarkDescription)
}

final class RegistryCardTableViewCell: UITableViewCell {
    
    static let identifier = "RegistryCardTableViewCell"
    
    var addresses = [MarkDescription]()
    
    var isTapOnAddresses = false {
        didSet {
            if isTapOnAddresses {
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.tableView.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.tableView.isHidden = true
                }
            }
        }
    }
    
    var delegate: RegistryCardTableViewCellDelegate?
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.estimatedRowHeight = UITableView.automaticDimension
        table.dataSource = self
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
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
        let stackView = UIStackView(arrangedSubviews: [cardID, accidentTitle, orgTitle, time, showAddresses, tableView])
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
    
    lazy var showAddresses: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapShowAdresses))
        label.addGestureRecognizer(gesture)
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
        addresses = []
        isTapOnAddresses = false
        
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
        
        let addresses = Array(Set(communalService.mark.map { $0.address }))
        self.addresses = communalService.mark.uniques(by: \.address)
        
        tableView.reloadData()
        
        showAddresses.text = "Отключено адресов: \(addresses.count)"
        
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

extension Array {

    func uniques<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return reduce([]) { result, element in
            let alreadyExists = (result.contains(where: { $0[keyPath: keyPath] == element[keyPath: keyPath] }))
            return alreadyExists ? result : result + [element]
        }
    }
}


extension RegistryCardTableViewCell {
    
    @objc func didTapShowAdresses() {
        isTapOnAddresses.toggle()
        
        delegate?.updateTableWhenShowAddresses()
    }
    
}

extension RegistryCardTableViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = addresses[indexPath.row].address
        
        return cell
    }
    
}

extension RegistryCardTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = addresses[indexPath.row]
        delegate?.didTapAddress(item)
    }
    
}

extension RegistryCardTableViewCell {
    
    func setConstraints() {
        
        tableView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(25)
        }
        
        stackViewAccidentIcon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.leading.equalToSuperview().inset(5)
            $0.width.equalTo(30)
        }
        
        separator.snp.makeConstraints {
            $0.leading.equalTo(stackViewAccidentIcon.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(1)
        }
        
        stackViewMainInformation.snp.makeConstraints {
            $0.leading.equalTo(separator).offset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.top.bottom.equalToSuperview().inset(5)
        }
    }
}
