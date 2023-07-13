//
//  CityCleaningMachineTypeView.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class CityCleaningMachineTypeViewController: UIViewController {
    
    private var machineTypes = [CityCleaningTypeElement]()
    private var selectedMachineTypes = BehaviorRelay<Set<String>>(value: [])
    
    var selectedMachineTypesObservable: Observable<Set<String>> {
        selectedMachineTypes.asObservable()
    }
    
    lazy var allTypesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [typesSwitcherTitle, allTypesSwitcher, allTypesSwitcherTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var typesSwitcherTitle: UILabel = {
        let label = UILabel()
        label.text = "Виды техники: "
        return label
    }()
    
    lazy var allTypesSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        switcher.addTarget(self, action: #selector(didSwitchToAllTypes), for: .valueChanged)
        return switcher
    }()
    
    lazy var allTypesSwitcherTitle: UILabel = {
        let label = UILabel()
        label.text = "Все"
        return label
    }()
    
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
        view.addSubview(allTypesStackView)
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        
        allTypesStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(allTypesStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setSelectedAllMachineTypes() {
        selectedMachineTypes.accept(Set(machineTypes.map { $0.type } ))
    }
    
    func configure(dataSource: [CityCleaningTypeElement]) {
        self.machineTypes = dataSource
        setSelectedAllMachineTypes()
        collectionView.reloadData()
    }
    
}

extension CityCleaningMachineTypeViewController {
    
    @objc func didSwitchToAllTypes(_ sender: UISwitch) {
        if sender.isOn {
            setSelectedAllMachineTypes()
        } else {
            selectedMachineTypes.accept([])
        }
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
        
        cell.isTypeMachineSelected = selectedMachineTypes.value.contains(cell.machineType)
        
        
        cell
            .typeAndIsSelectedObservable
            .subscribe { [unowned self] (typeTitle: String, isSelected: Bool) in
                var updatedSet = selectedMachineTypes.value
                if isSelected {
                    updatedSet.insert(typeTitle)
                } else {
                    updatedSet.remove(typeTitle)
                }
                selectedMachineTypes.accept(updatedSet)
            }
            .disposed(by: cell.bag)
        
        return cell
    }
    
}

extension CityCleaningMachineTypeViewController: UICollectionViewDelegate {
    
}
