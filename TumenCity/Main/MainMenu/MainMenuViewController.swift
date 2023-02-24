//
//  MainMenuViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit

enum MenuItemType: String {
    case sport = "Спорт"
    case cityCleaning = "Уборка города"
    case bikePaths = "Велодорожки"
    case urbanImprovements = "Благоустройство"
    case communalServices = "Отключение ЖКУ"
    case roadClose = "Перекрытие дорог"
    case digWork = "Земляные работы"
    case tradeObjects = "Нестационарные торговые объекты"
    case none
}

final class MainMenuViewController: UIViewController {
    
    let menuTypes: [MenuItemType] = [.sport, .cityCleaning, .bikePaths, .urbanImprovements, .communalServices, .roadClose, .digWork, .tradeObjects]
    let menuTitles = ["Спорт", "Уборка города", "Велодорожки", "Благоустройство", "Отключение ЖКУ", "Перекрытие дорог", "Земляные работы", "Нестационарные торговые объекты"]
    let images = ["main-1", "main-2", "main-3"]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout(section: .createMainLayout())
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: MenuCollectionViewCell.identifier)
        collectionView.register(MenuHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundView = imageBackground
        return collectionView
    }()
    
    lazy var imageBackground: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: images.randomElement()!)
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Меню"
//        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
    }

}

extension MainMenuViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menuTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as! MenuCollectionViewCell
        
        cell.configure(with: .add, menuTitle: menuTitles[indexPath.row], type: menuTypes[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuHeaderCollectionReusableView.identifier, for: indexPath)
        return header
    }
    
}

extension MainMenuViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tappedItem = collectionView.cellForItem(at: indexPath) as? MenuCollectionViewCell else { return }
        let type = tappedItem.type
        
        switch type {
        case .sport:
            return
        case .cityCleaning:
            return
        case .bikePaths:
            return
        case .urbanImprovements:
            return
        case .communalServices:
            let vc = CommunalServicesViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .roadClose:
            return
        case .digWork:
            return
        case .tradeObjects:
            return
        case .none:
            return
        }
    }
    
}
