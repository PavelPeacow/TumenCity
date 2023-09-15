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
    typealias SelectedContractors = [String : Set<String>]
    
    let viewModel = CityCleaningFilterViewModel()
    let bag = DisposeBag()
    
    var selectedMachineTypes = Set<String>()
    private var selectedMachineTypesSubject = PublishSubject<Set<String>>()
    var selectedMachineTypesObservable: Observable<Set<String>> {
        selectedMachineTypesSubject.asObservable()
    }
    
    var selectedContractors = SelectedContractors()
    private var selectedContractorsSubject = PublishSubject<SelectedContractors>()
    var selectedContractorsObservable: Observable<SelectedContractors> {
        selectedContractorsSubject.asObservable()
    }
    
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
        btn.backgroundColor = .secondarySystemBackground
        btn.addTarget(self, action: #selector(showContextMenu), for: .touchUpInside)
        let menu = createFilterMenuForBtn()
        btn.showsMenuAsPrimaryAction = true
        btn.menu = menu
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
    
    lazy var loadingController = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
        setUpBindingsForFilterViewControllers()
        setUpConstaints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedMachineTypesSubject.onNext(selectedMachineTypes)
        selectedContractorsSubject.onNext(selectedContractors)
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
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self)
                } else {
                    loadingController.removeLoadingViewControllerIn(self)
                    typeMachineFilterViewController.configure(dataSource: viewModel.filterItems)
                    contractorsFilterViewController.configure(dataSource: viewModel.contractorsItems)
                }
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForFilterViewControllers() {
        typeMachineFilterViewController
            .selectedMachineTypesObservable
            .subscribe(onNext: { [unowned self] machineTypes in
                selectedMachineTypes = machineTypes
                print(machineTypes)
            })
            .disposed(by: bag)
        
        contractorsFilterViewController
            .selectedContractorsObservable
            .subscribe(onNext: { [unowned self] contractors in
                selectedContractors = contractors
                print(contractors)
            })
            .disposed(by: bag)
    }
    
    private func createFilterMenuForBtn() -> UIMenu {
//        let controlEnvMenuItem = UIAction(title: "Контроль среды",
//                                          image: .init(named: "envControl")) { [unowned self] _ in
//            changeSelectedFilter(filterType: .controlEnvMenuItem)
//        }
        
        let indicatorsMenuItem = UIAction(title: "Показатели",
                                          image: .init(named: "indicators")) { [unowned self] _ in
            changeSelectedFilter(filterType: .indicatorsMenuItem)
        }
        
        let contractorsMenuItem = UIAction(title: "Подрядчики",
                                           image: .init(named: "contractors")) { [unowned self] _ in
            changeSelectedFilter(filterType: .contractorsMenuItem)
        }
        
        let typeMenuItem = UIAction(title: "Тип техники",
                                    image: .init(named: "machineType")) { [unowned self] _ in
            changeSelectedFilter(filterType: .typeMenuItem)
        }
        
        return UIMenu(children: [indicatorsMenuItem, contractorsMenuItem, typeMenuItem])
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
        func setUpConstraintsForChildFilter(_ child: UIViewController) {
            child.view.snp.makeConstraints {
                $0.top.equalTo(selectFilterStackView.snp.bottom).offset(5)
                $0.leading.trailing.equalToSuperview()
                $0.bottomMargin.equalToSuperview()
            }
        }
        
        
        selectFilterStackView.snp.makeConstraints {
            $0.topMargin.equalToSuperview().inset(5)
            $0.centerX.equalToSuperview()
        }
        
        indicatorBtn.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalToSuperview()
        }

        setUpConstraintsForChildFilter(typeMachineFilterViewController)
        
        setUpConstraintsForChildFilter(indicatorsFilterViewController)
        
        setUpConstraintsForChildFilter(contractorsFilterViewController)
        
        setUpConstraintsForChildFilter(envControlFilterViewController)
    }
    
}

#Preview {
    CityCleaningFilterViewController()
}
