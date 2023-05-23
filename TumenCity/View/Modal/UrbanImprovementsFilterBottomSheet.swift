//
//  UrbanImprovementsFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import UIKit

final class UrbanImprovementsFilterCell: UITableViewCell {
    
    static let identifier = "UrbanImprovementsFilterCell"
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterIcon, filterTitle])
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var filterIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var filterTitle: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.top.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(icon: UIImage?, title: String) {
        filterIcon.image = icon
        filterTitle.text = title
    }
    
}

final class UrbanImprovementsFilterBottomSheet: CustomBottomSheet {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UrbanImprovementsFilterCell.self, forCellReuseIdentifier: UrbanImprovementsFilterCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
        }
        
        let size = tableView.contentSize.height + topInset * 2
        
        preferredContentSize = CGSize(width: view.bounds.width, height: size)
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UrbanImprovementsFilterCell.identifier, for: indexPath) as! UrbanImprovementsFilterCell
        
        cell.configureCell(icon: UIImage(systemName: "person"), title: "Looool")
        
        return cell
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDelegate { }
