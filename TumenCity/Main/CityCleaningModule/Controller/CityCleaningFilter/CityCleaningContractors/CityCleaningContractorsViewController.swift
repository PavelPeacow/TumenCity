//
//  CityCleaningContractorsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import RxSwift

class CityCleaningContractorsViewController: UIViewController {
    
    var contractors = [CityCleaningContractorElement]()
    
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
            let switcherView = SwitchWithTitle(switchTitle: $0.council, isOn: true,
                                               onTintColor: .black, backgroundColor: .secondarySystemBackground)
            scrollViewStackView.addArrangedSubview(switcherView)
        }
    }
    
    func configure(dataSource: [CityCleaningContractorElement]) {
        contractors = dataSource
        contractorsCollectionView.reloadData()
        createMainContractorsSwitches()
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
        cell.configure(typeTitle: title)
        
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
