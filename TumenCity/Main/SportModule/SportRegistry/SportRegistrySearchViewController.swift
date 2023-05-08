//
//  SportRegistrySearchViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 08.05.2023.
//

import UIKit

protocol SportRegistrySearchViewControllerDelegate {
    func didTapSearchResult(_ result: SportElement)
}

class SportRegistrySearchViewController: UITableViewController {
    
    var sportElements = [SportElement]()
    var filteredSportElements = [SportElement]()
    
    var delegate: SportRegistrySearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    func configure(sportElements: [SportElement]) {
        self.sportElements = sportElements
        filteredSportElements = sportElements
    }
    
    func filterSearch(with searchText: String) {
        if filteredSportElements.isEmpty {
            filteredSportElements = sportElements
        }
        filteredSportElements = sportElements.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
}

extension SportRegistrySearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSportElements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = filteredSportElements[indexPath.row].title
        
        return cell
    }
    
}

extension SportRegistrySearchViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didTapSearchResult(filteredSportElements[indexPath.row])
    }
    
}
