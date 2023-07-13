//
//  CityCleaningMachineTypeViewCell.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import SnapKit
import RxSwift

class CityCleaningMachineTypeViewCell: UICollectionViewCell {
    typealias SelectedMachineType = (typeTitle: String, isSelected: Bool)
    
    static let identifier = "CityCleaningMachineTypeViewCell"
    
    var isTypeMachineSelected = true {
        willSet {
            switcher.isOn = newValue
        }
    }
    var bag = DisposeBag()
    
    var machineType = ""
    
    private var typeAndIsSelected = PublishSubject<(SelectedMachineType)>()
    var typeAndIsSelectedObservable: Observable<SelectedMachineType> {
        typeAndIsSelected.asObservable()
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [typeImage, typeTitle])
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        switcher.addTarget(self, action: #selector(didSwitch), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    lazy var typeImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var typeTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
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
        machineType = ""
        bag = DisposeBag()
    }
    
    func configure(typeImage: UIImage, typeTitle: String) {
        self.typeImage.image = typeImage
        self.typeTitle.text = typeTitle
        machineType = typeTitle
    }
    
    private func setUpCell() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(switcher)
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 15
        
        contentStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(switcher.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(5)
        }
        
        switcher.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.width.equalTo(44)
        }
                
        typeImage.snp.makeConstraints {
            $0.size.equalTo(44)
        }
    }
    
}

extension CityCleaningMachineTypeViewCell {
    
    @objc func didSwitch(_ sender: UISwitch) {
        isTypeMachineSelected = sender.isOn
        typeAndIsSelected
            .onNext((machineType, isTypeMachineSelected))
    }
    
}
