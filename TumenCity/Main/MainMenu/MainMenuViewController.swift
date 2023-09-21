//
//  MainMenuViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit
import SnapKit

enum MenuItemType: String {
    case sport = "Спорт"
    case cityCleaning = "Уборка города"
    case bikePaths = "Велодорожки"
    case urbanImprovements = "Благоустройство"
    case communalServices = "Отключение ЖКУ"
    case roadClose = "Перекрытие дорог"
    case digWork = "Земляные работы"
    case tradeObjects = "Нестационарные торговые объекты"
}

final class MainMenuViewController: UIViewController {
    
    let menuTypes: [MenuItemType] = [.sport, .cityCleaning, .bikePaths, .urbanImprovements, .communalServices, .roadClose, .digWork, .tradeObjects]
    let menuTitles = ["Спорт", "Уборка города", "Велодорожки", "Благоустройство", "Отключение ЖКУ", "Перекрытие дорог", "Земляные работы", "Нестационарные торговые объекты"]
    let images = ["main-1", "main-2", "main-3"]
    
    private let router: MainMenuRouterProtocol
    
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
    
    init(router: MainMenuRouterProtocol) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.topMargin.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setClearAppearence()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setStandartAppearence()
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
        
        let image = UIImage(named: menuTypes[indexPath.row].rawValue) ?? .add
        
        cell.configure(with: image, menuTitle: menuTitles[indexPath.row], type: menuTypes[indexPath.row])
        
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
        tappedItem.tapAnimation()
        
        let mappedType = mapMenuItemTypeToRouterPath(type)
        router.navigateTo(path: mappedType, from: self)
    }

    private func mapMenuItemTypeToRouterPath(_ itemType: MenuItemType) -> MainMenuRouterPaths {
        switch itemType {
        case .sport:
            return .sport
        case .cityCleaning:
            return .cityCleaning
        case .bikePaths:
            return .bikePaths
        case .urbanImprovements:
            return .urbanImprovements
        case .communalServices:
            return .communalServices
        case .roadClose:
            return .roadClose
        case .digWork:
            return .digWork
        case .tradeObjects:
            return .tradeObjects
        }
    }
}
