//
//  RegistySearchResultViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 24.02.2023.
//

import UIKit

protocol RegistySearchResultViewControllerDelegate {
    func didTapResultAddress(_ mark: MarkDescription)
}

class RegistySearchResultViewController: UITableViewController {
    
    var addresses = [MarkDescription]()
    var filteredAdresses = [MarkDescription]()
    
    var delegate: RegistySearchResultViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    func configure(communalServicesFormatted: [CommunalServicesFormatted]) {
        communalServicesFormatted.forEach {
            addresses.append(contentsOf: $0.mark)
        }
        addresses = addresses.uniques(by: \.address)
        filteredAdresses = addresses
    }
    
    func filterSearch(with searchText: String) {
        if filteredAdresses.isEmpty {
            filteredAdresses = addresses
        }
        filteredAdresses = addresses.filter { $0.address.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
}

extension RegistySearchResultViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredAdresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = filteredAdresses[indexPath.row].address
        
        return cell
    }
    
}

extension RegistySearchResultViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didTapResultAddress(filteredAdresses[indexPath.row])
    }
    
}
