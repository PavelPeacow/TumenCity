//
//  CityCleaningMachineTypeView.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import SnapKit

final class CityCleaningMachineTypeViewController: UIViewController {
    
    var machineTypes = [CityCleaningTypeElement]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            
            return section
        }
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(CityCleaningMachineTypeViewCell.self, forCellWithReuseIdentifier: CityCleaningMachineTypeViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(dataSource: [CityCleaningTypeElement]) {
        self.machineTypes = dataSource
        collectionView.reloadData()
    }
    
}

extension CityCleaningMachineTypeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        machineTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCleaningMachineTypeViewCell.identifier, for: indexPath) as! CityCleaningMachineTypeViewCell
        let image = UIImage(named: "type-\(machineTypes[indexPath.item].id)") ?? .actions
        let title = machineTypes[indexPath.item].type
        cell.configure(typeImage: image, typeTitle: title)
        return cell
    }
    
}

extension CityCleaningMachineTypeViewController: UICollectionViewDelegate {
    
}
