//
//  SportRegistryView.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit
import RxSwift

final class SportRegistryView: UIView {
    
    private let bag = DisposeBag()
    private let selectedSportAddress = PublishSubject<Address>()
    var selectedSportAddressObservable: Observable<Address> {
        selectedSportAddress.asObservable()
    }
    
    var sportElements = [SportElement]()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(SportRegistryTableViewCell.self, forCellReuseIdentifier: SportRegistryTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.allowsSelection = false
        table.estimatedRowHeight = UITableView.automaticDimension
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(sportElements: [SportElement]) {
        self.sportElements = sportElements
    }
    
}

extension SportRegistryView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sportElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SportRegistryTableViewCell.identifier, for: indexPath) as! SportRegistryTableViewCell
        
        let sportElement = sportElements[indexPath.row]
        cell.configure(sportElement: sportElement)
        
        cell
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] address in
                selectedSportAddress
                    .onNext(address)
            })
            .disposed(by: bag)
        
        return cell
    }
    
}

extension SportRegistryView: UITableViewDelegate { }
