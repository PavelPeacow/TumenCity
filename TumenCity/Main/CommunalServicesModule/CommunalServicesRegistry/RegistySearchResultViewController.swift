//
//  RegistySearchResultViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 24.02.2023.
//

import UIKit
import RxSwift

class RegistySearchResultViewController: UITableViewController {
    
    private var addresses = BehaviorSubject<[MarkDescription]>(value: [])
    private var filteredAdresses = BehaviorSubject<[MarkDescription]>(value: [])
    private let bag = DisposeBag()

    private var selectedAddressElement = PublishSubject<MarkDescription>()
    var selectedAddressesElementObservable: Observable<MarkDescription> {
        selectedAddressElement.asObservable()
    }
    
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
    }

    private func setUpBindings() {
        Observable.combineLatest(filteredAdresses, addresses)
            .map { filteredElements, allElements in
                filteredElements.isEmpty ? allElements : filteredElements
            }
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { (row, element, cell) in
                cell.textLabel?.text = element.address
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(MarkDescription.self)
            .subscribe(onNext: { [unowned self] addressElement in
                selectedAddressElement
                    .onNext(addressElement)
            })
            .disposed(by: bag)
    }
    
    func configure(communalServicesFormatted: [CommunalServicesFormatted]) {
        var formAddresses = [MarkDescription]()
        communalServicesFormatted.forEach {
            formAddresses.append(contentsOf: $0.mark)
        }
        formAddresses = formAddresses.uniques(by: \.address)
        addresses
            .onNext(formAddresses)
        filteredAdresses
            .onNext(formAddresses)
    }
    
    func filterSearch(with searchText: String) {
        addresses
            .map { elements in
                elements.filter { $0.address.lowercased().contains(searchText.lowercased()) }
            }
            .bind(to: filteredAdresses)
            .disposed(by: bag)
    }
}
