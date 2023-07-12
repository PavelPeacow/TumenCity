//
//  CityCleaningFilterViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 12.07.2023.
//

import UIKit
import SnapKit
import RxSwift

enum CityCleaningFilterSelectedType {
    case controlEnvMenuItem
    case indicatorsMenuItem
    case contractorsMenuItem
    case typeMenuItem
}

final class CityCleaningFilterViewController: UIViewController {
    
    let viewModel = CityCleaningFilterViewModel()
    let bag = DisposeBag()
    
    lazy var selectFilterStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [selectFilterTypeTitle, indicatorBtn])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    lazy var selectFilterTypeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = "Выбранный индикатор"
        label.textAlignment = .center
        return label
    }()
    
    lazy var indicatorBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Вид техники", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.setImage(.init(named: "machineType"), for: .normal)
        btn.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 20)
        btn.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: -10)
        btn.imageEdgeInsets = .init(top: -10, left: -10, bottom: -10, right: -10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 12
        btn.backgroundColor = .systemGroupedBackground
        btn.addTarget(self, action: #selector(showContextMenu), for: .touchUpInside)
        let menu = createFilterMenuForBtn()
        if #available(iOS 14.0, *) {
            btn.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 14.0, *) {
            btn.menu = menu
        } else {
            // Fallback on earlier versions
        }
        return btn
    }()

    lazy var typeMachineFilterViewController: CityCleaningMachineTypeViewController = {
        let view = CityCleaningMachineTypeViewController()
        addChildViewController(view)
        return view
    }()
    
    lazy var contractorsFilterViewController: CityCleaningContractorsViewController = {
        let view = CityCleaningContractorsViewController()
        addChildViewController(view)
        return view
    }()
    
    lazy var indicatorsFilterViewController: CityCleaningIndicatorsViewController = {
        let view = CityCleaningIndicatorsViewController()
        addChildViewController(view)
        return view
    }()
    
    lazy var envControlFilterViewController: CityCleaningEnvControlViewController = {
        let view = CityCleaningEnvControlViewController()
        addChildViewController(view)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
        setUpConstaints()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(selectFilterStackView)
        showSelectedFilterViewController(typeMachineFilterViewController)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                if !isLoading {
                    typeMachineFilterViewController.configure(dataSource: viewModel.filterItems)
                }
            })
            .disposed(by: bag)
    }
    
    private func createFilterMenuForBtn() -> UIMenu {
        let controlEnvMenuItem = UIAction(title: "Контроль среды") { [unowned self] _ in
            changeSelectedFilter(filterType: .controlEnvMenuItem)
        }
        
        let indicatorsMenuItem = UIAction(title: "Индикаторы") { [unowned self] _ in
            changeSelectedFilter(filterType: .indicatorsMenuItem)
        }
        
        let contractorsMenuItem = UIAction(title: "Подрядчики") { [unowned self] _ in
            changeSelectedFilter(filterType: .contractorsMenuItem)
        }
        
        let typeMenuItem = UIAction(title: "Тип техники") { [unowned self] _ in
            changeSelectedFilter(filterType: .typeMenuItem)
        }
        
        return UIMenu(children: [controlEnvMenuItem, indicatorsMenuItem,
                                    contractorsMenuItem, typeMenuItem])
    }
    
    private func changeSelectedFilter(filterType: CityCleaningFilterSelectedType) {
        switch filterType {
            
        case .controlEnvMenuItem:
            changeSelectedFilterTitleAndImage(title: "Контроль среды", image: .init(named: "envControl"))
            showSelectedFilterViewController(envControlFilterViewController)
        case .indicatorsMenuItem:
            changeSelectedFilterTitleAndImage(title: "Индикаторы", image: .init(named: "indicators"))
            showSelectedFilterViewController(indicatorsFilterViewController)
        case .contractorsMenuItem:
            changeSelectedFilterTitleAndImage(title: "Подрядчики", image: .init(named: "contractors"))
            showSelectedFilterViewController(contractorsFilterViewController)
        case .typeMenuItem:
            changeSelectedFilterTitleAndImage(title: "Тип техники", image: .init(named: "machineType"))
            showSelectedFilterViewController(typeMachineFilterViewController)
        }
    }
    
    private func changeSelectedFilterTitleAndImage(title: String?, image: UIImage?) {
        indicatorBtn.setTitle(title, for: .normal)
        indicatorBtn.setImage(image, for: .normal)
    }
    
    private func showSelectedFilterViewController(_ viewController: UIViewController) {
        [typeMachineFilterViewController.view, contractorsFilterViewController.view, indicatorsFilterViewController.view, envControlFilterViewController.view].forEach {
            $0?.isHidden = true
        }
        viewController.view.isHidden = false
    }
    
}

extension CityCleaningFilterViewController {
    
    @objc func showContextMenu(_ sender: UIButton) {
        let menu = UIMenuController.shared
        menu.showMenu(from: sender, rect: sender.bounds)
    }
    
}

extension CityCleaningFilterViewController {
    
    func setUpConstaints() {
        selectFilterStackView.snp.makeConstraints {
            $0.topMargin.equalToSuperview().inset(5)
            $0.centerX.equalToSuperview()
        }
        
        indicatorBtn.snp.makeConstraints {
            $0.height.equalTo(44)
        }

        typeMachineFilterViewController.view.snp.makeConstraints {
            $0.top.equalTo(selectFilterStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottomMargin.equalToSuperview()
        }
        
        indicatorsFilterViewController.view.snp.makeConstraints {
            $0.top.equalTo(selectFilterStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottomMargin.equalToSuperview()
        }
        
        contractorsFilterViewController.view.snp.makeConstraints {
            $0.top.equalTo(selectFilterStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottomMargin.equalToSuperview()
        }
        
        envControlFilterViewController.view.snp.makeConstraints {
            $0.top.equalTo(selectFilterStackView.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottomMargin.equalToSuperview()
        }
    }
    
}

#Preview {
    CityCleaningFilterViewController()
}
