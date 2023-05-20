//
//  SportRegistryView.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit

protocol SportRegistryViewDelegate {
    func didGetAddress(_ address: Address)
}

final class SportRegistryView: UIView {
    
    var sportElements = [SportElement]()
    
    var delegate: SportRegistryViewDelegate?
    
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
    
}

extension SportRegistryView: SportRegistryTableViewCellDelegate {
    
    func didTapAddress(_ address: Address) {
        delegate?.didGetAddress(address)
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
        cell.delegate = self
        
        return cell
    }
    
}

extension SportRegistryView: UITableViewDelegate { }
