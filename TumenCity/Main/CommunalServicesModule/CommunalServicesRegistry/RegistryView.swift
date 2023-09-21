//
//  RegistryView.swift
//  TumenCity
//
//  Created by Павел Кай on 22.02.2023.
//

import UIKit
import RxSwift

final class RegistryView: UIView {
    
    var cards = [CommunalServicesFormatted]() {
        willSet {
            emptyDataMessageView.isHidden = !newValue.isEmpty
        }
    }
    
    private let bag = DisposeBag()
    private let selectedAddress = PublishSubject<MarkDescription>()
    var selectedAddressObservable: Observable<MarkDescription> {
        selectedAddress.asObservable()
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(RegistryCardTableViewCell.self, forCellReuseIdentifier: RegistryCardTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.allowsSelection = false
        table.estimatedRowHeight = UITableView.automaticDimension
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
        
    lazy var emptyDataMessageView: EmptyDataMessageView = {
        let view = EmptyDataMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        addSubview(emptyDataMessageView)
        
        emptyDataMessageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RegistryView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistryCardTableViewCell.identifier, for: indexPath) as! RegistryCardTableViewCell
        
        let card = cards[indexPath.row]
        cell.configure(communalService: card)
        
        cell
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] address in
                selectedAddress
                    .onNext(address)
            })
            .disposed(by: bag)
        
        cell
            .updateTableWhenShowAddressesObservable
            .subscribe(onNext: {
                UIView.animate(withDuration: 0.25) {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            })
            .disposed(by: bag)
        
        return cell
    }
    
}

extension RegistryView: UITableViewDelegate { }
