//
//  MainMenuViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    let menuTitles = ["Спорт", "Уборка города", "Велодорожки", "Благоустройство", "Отключение ЖКУ", "Перекрытие дорог", "Земляные работы", "Нестационарные торговые объекты"]
    let images = ["main-1", "main-2", "main-3"]
    
    lazy var logoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainMenuLogo, mainMenuTitle])
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var mainMenuLogo: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var mainMenuTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .black)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Портал цифровых сервисов Тюмень"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageBackground: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: images.randomElement()!)
        return image
    }()
    
    lazy var menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageBackground)
        view.addSubview(logoStackView)
        view.addSubview(menuStackView)
        navigationController?.navigationBar.isOpaque = true
        addMenuItems()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        imageBackground.frame = view.bounds
    }
    
    private func addMenuItems() {
        for item in menuTitles {
            let menuItemView = MenuItemButton(menuIcon: UIImage(systemName: "house")!, menuTitle: item)
            menuItemView.addTarget(self, action: #selector(didTapMenuItem(_:)), for: .touchUpInside)
            menuStackView.addArrangedSubview(menuItemView)
        }
    }

}

extension MainMenuViewController {
    
    @objc func didTapMenuItem(_ sender: UIButton) {
        guard let tappedBtn = sender as? MenuItemButton else { return }
        let type = tappedBtn.type
        
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

extension MainMenuViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            logoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            logoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            logoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            menuStackView.topAnchor.constraint(equalTo: mainMenuTitle.bottomAnchor, constant: 15),
            menuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            menuStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
    }
    
}
