//
//  CityCleaningContractorsCell.swift
//  TumenCity
//
//  Created by Павел Кай on 14.07.2023.
//

import UIKit
import RxSwift

final class CityCleaningContractorsCell: UICollectionViewCell {
    typealias SelectedContractor = (contractorTitle: String, council: String, isSelected: Bool)
    
    static let identifier = "CityCleaningContractorsCell"
    
    var isTypeContractorSelected = true {
        willSet {
            switcher.switcher.isOn = newValue
        }
    }
    var bag = DisposeBag()
    
    lazy var cellTitle = ""
    lazy var council = ""
    
    private var typeAndIsSelected = PublishSubject<(SelectedContractor)>()
    var typeAndIsSelectedObservable: Observable<SelectedContractor> {
        typeAndIsSelected.asObservable()
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [switcher])
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    lazy var switcher: SwitchWithTitle = {
        let sw = SwitchWithTitle(switchTitle: cellTitle, isOn: true, onTintColor: .systemOrange)
        sw.switcher.addTarget(self, action: #selector(didSwitch), for: .valueChanged)
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellTitle = ""
        council = ""
        bag = DisposeBag()
    }
    
    func configure(typeTitle: String, council: String) {
        self.switcher.switchTitle.text = typeTitle
        cellTitle = typeTitle
        self.council = council
    }
    
    private func setUpCell() {
        contentView.addSubview(contentStackView)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 15
        
        contentStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(5)
        }
    }
    
}

extension CityCleaningContractorsCell {
    
    @objc func didSwitch(_ sender: UISwitch) {
        isTypeContractorSelected = sender.isOn
        typeAndIsSelected
            .onNext((cellTitle, council, isTypeContractorSelected))
    }
    
}
