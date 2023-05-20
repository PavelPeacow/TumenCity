//
//  RegistryView.swift
//  TumenCity
//
//  Created by Павел Кай on 22.02.2023.
//

import UIKit

protocol RegistryViewDelegate {
    func didGetAddress(_ mark: MarkDescription)
}

final class RegistryView: UIView {
    
    var cards = [CommunalServicesFormatted]()
    
    var delegate: RegistryViewDelegate?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RegistryView: RegistryCardTableViewCellDelegate {
    
    func didTapAddress(_ mark: MarkDescription) {
        delegate?.didGetAddress(mark)
    }
    
    func updateTableWhenShowAddresses() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
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
        cell.delegate = self
        
        return cell
    }
    
}

extension RegistryView: UITableViewDelegate { }
