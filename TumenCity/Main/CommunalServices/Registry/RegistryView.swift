//
//  RegistryView.swift
//  TumenCity
//
//  Created by Павел Кай on 22.02.2023.
//

import UIKit

final class RegistryView: UIView {
    
    var cards = [CommunalServicesFormatted]()
    
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
        setConstraints()
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
        
        return cell
    }
    
}

extension RegistryView: UITableViewDelegate {
    
}

extension RegistryView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
