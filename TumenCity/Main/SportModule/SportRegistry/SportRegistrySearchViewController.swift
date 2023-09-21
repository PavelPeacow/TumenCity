//
//  SportRegistrySearchViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class SportRegistrySearchViewController: UITableViewController {
    
    private var sportElements = BehaviorSubject<[SportElement]>(value: [])
    private var filteredSportElements = BehaviorSubject<[SportElement]>(value: [])
    private let bag = DisposeBag()
    
    private var selectedSportElement = PublishSubject<SportElement>()
    var selectedSportElementObservable: Observable<SportElement> {
        selectedSportElement.asObservable()
    }
    
    lazy var emptyDataMessageView: EmptyDataMessageView = {
        let view = EmptyDataMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = nil
        tableView.dataSource = nil
        view.addSubview(emptyDataMessageView)
        
        emptyDataMessageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
        }
    }
    
    private func setUpBindings() {
        Observable.combineLatest(filteredSportElements, sportElements)
            .map { filteredElements, allElements in
                self.emptyDataMessageView.isHidden = !filteredElements.isEmpty
                return filteredElements
            }
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { (row, element, cell) in
                cell.textLabel?.text = element.title
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(SportElement.self)
            .subscribe(onNext: { [unowned self] sportElement in
                selectedSportElement
                    .onNext(sportElement)
            })
            .disposed(by: bag)
    }
    
    func configure(sportElements: [SportElement]) {
        self.sportElements
            .onNext(sportElements)
        filteredSportElements
            .onNext(sportElements)
    }
    
    func filterSearch(with searchText: String) {
        sportElements
            .map { elements in
                elements.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            }
            .bind(to: filteredSportElements)
            .disposed(by: bag)
    }
    
}
