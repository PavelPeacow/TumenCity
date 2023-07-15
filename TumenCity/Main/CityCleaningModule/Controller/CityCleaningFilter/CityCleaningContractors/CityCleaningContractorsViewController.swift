//
//  CityCleaningContractorsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import RxSwift
import RxRelay

class CityCleaningContractorsViewController: UIViewController {
    typealias SelectedContractors = [String : Set<String>]
    
    private var contractors = [CityCleaningContractorElement]()
    private var selectedContractors = BehaviorRelay<SelectedContractors>(value: [:])
    
    var selectedContractorsObservable: Observable<SelectedContractors> {
        selectedContractors.asObservable()
    }
    
    lazy var mainContractorsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainContractorsTitle, mainContractorsScrollView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var mainContractorsTitle: UILabel = {
        let label = UILabel()
        label.text = "Управляющие организации:"
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var mainContractorsScrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    lazy var scrollViewStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var contractorsCollectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CityCleaningContractorsCell.self,
                                forCellWithReuseIdentifier: CityCleaningContractorsCell.identifier)
        collectionView.register(CityCleaningContractorsHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CityCleaningContractorsHeader.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstraints()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainContractorsStackView)
        mainContractorsScrollView.addSubview(scrollViewStackView)
        view.addSubview(contractorsCollectionView)
    }
    
    private func createMainContractorsSwitches() {
        contractors.forEach {
            let switcherView = SwitchWithTitleCouncil(switchTitle: $0.councilFormatted, isOn: true,
                                                      onTintColor: .black,
                                                      backgroundColor: .secondarySystemBackground,
                                                      type: .init(rawValue: $0.councilFormatted) ?? .ddit)
            switcherView.switcher.addTarget(self,
                                            action: #selector(didTapMainContractorsSwitcher),
                                            for: .valueChanged)
            scrollViewStackView.addArrangedSubview(switcherView)
        }
    }
    
    private func setSelectedAllContractors() {
        var councilsAndContractors = [String : Set<String>]()
        
        let councilsTitles = contractors.map { $0.councilFormatted }
        let allContractorsByCouncil = contractors.map { $0.contractor }
        
        councilsTitles.enumerated().forEach { index, title in
            councilsAndContractors[title] = Set(allContractorsByCouncil[index].map { $0.contractor })
        }
        selectedContractors.accept(councilsAndContractors)
    }
    
    private func setSelectedAllConctractorsByCouncil(_ council: SwitchWithTitleCouncilType) {
        var dic = selectedContractors.value
        var updated = selectedContractors.value[council.rawValue] ?? Set()
        let councilsTitles = contractors.map { $0.councilFormatted }
        let allContractorsByCouncil = contractors.map { $0.contractor }
        
        councilsTitles.enumerated().forEach { index, title in
            if title == council.rawValue {
                let contractors = allContractorsByCouncil[index].map { $0.contractor }
                contractors.forEach { updated.insert($0) }
            }
        }
        dic[council.rawValue] = updated
        selectedContractors.accept(dic)
    }
    
    private func setUnselectedAllConctractorsByCouncil(_ council: SwitchWithTitleCouncilType) {
        var dic = selectedContractors.value
        var updated = selectedContractors.value[council.rawValue] ?? Set()
        updated = Set()
        dic[council.rawValue] = updated
        selectedContractors.accept(dic)
    }
    
    private func reactToMainContractorsSwitchStateChanges(isOn: Bool, council: SwitchWithTitleCouncilType) {
        isOn ? setSelectedAllConctractorsByCouncil(council) : setUnselectedAllConctractorsByCouncil(council)
        contractorsCollectionView.reloadData()
    }
    
    func configure(dataSource: [CityCleaningContractorElement]) {
        contractors = dataSource
        setSelectedAllContractors()
        contractorsCollectionView.reloadData()
        createMainContractorsSwitches()
    }
    
}

extension CityCleaningContractorsViewController {
    @objc func didTapMainContractorsSwitcher(_ sender: UISwitch) {
        guard let switchView = sender.superview?.superview as? SwitchWithTitleCouncil else { return }
        let councilType = switchView.type
        
        switch councilType {
        case .ddit:
            reactToMainContractorsSwitchStateChanges(isOn: sender.isOn, council: .ddit)
        case .vao:
            reactToMainContractorsSwitchStateChanges(isOn: sender.isOn, council: .vao)
        case .cao:
            reactToMainContractorsSwitchStateChanges(isOn: sender.isOn, council: .cao)
        case .lao:
            reactToMainContractorsSwitchStateChanges(isOn: sender.isOn, council: .lao)
        case .kao:
            reactToMainContractorsSwitchStateChanges(isOn: sender.isOn, council: .kao)
        }
    }
}

extension CityCleaningContractorsViewController {
    func setUpConstraints() {
        mainContractorsStackView.snp.makeConstraints {
            $0.topMargin.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(15)
        }
        
        mainContractorsScrollView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalToSuperview()
        }
        
        scrollViewStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        contractorsCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(mainContractorsStackView.snp.bottom).offset(5)
            $0.bottom.equalToSuperview()
        }
    }
}

extension CityCleaningContractorsViewController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        contractors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        contractors[section].contractor.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCleaningContractorsCell.identifier, for: indexPath) as! CityCleaningContractorsCell
        
        let title = contractors[indexPath.section].contractor[indexPath.item].contractor
        let council = contractors[indexPath.section].councilFormatted
        cell.configure(typeTitle: title, council: council)
        print(council)
        print(title)
        print(selectedContractors.value[council])
        cell.isTypeContractorSelected = selectedContractors.value[council]?.contains(title) ?? false
        
        cell
            .typeAndIsSelectedObservable
            .subscribe(onNext: { [unowned self] (contractorTitle, council, isSelected) in
                var dic = selectedContractors.value
                var updated = selectedContractors.value[council] ?? []
                if isSelected {
                    updated.insert(contractorTitle)
                } else {
                    updated.remove(contractorTitle)
                }
                dic[council] = updated
                print(dic)
                selectedContractors.accept(dic)
            })
            .disposed(by: cell.bag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: CityCleaningContractorsHeader.identifier,
                                                                         for: indexPath) as! CityCleaningContractorsHeader
            let title = contractors[indexPath.section].council
            header.configure(title: title)
            
            return header
        }
        return UICollectionReusableView()
    }
    
}

extension CityCleaningContractorsViewController: UICollectionViewDelegate {
    
}

#Preview {
    CityCleaningContractorsViewController()
}
