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
        view.layer.cornerRadius = 12
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
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(25)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filterTitle.text = nil
        filterIcon.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(icon: UIImage?, title: String) {
        filterIcon.image = icon
        filterTitle.text = title
    }
    
}

protocol UrbanImprovementsFilterBottomSheetDelegate: AnyObject {
    func didSelectFilter(_ filterID: Int)
}

final class UrbanImprovementsFilterBottomSheet: CustomBottomSheet {
    
    var filters = [UrbanFilter]()
    
    weak var delegate: UrbanImprovementsFilterBottomSheetDelegate?
    
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
            $0.height.equalToSuperview().inset(topInset)
        }
        

        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.height / 2)
        
    }
    
    func configure(filters: [UrbanFilter]) {
        self.filters = filters
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UrbanImprovementsFilterCell.identifier, for: indexPath) as! UrbanImprovementsFilterCell
        print("chw")
        cell.configureCell(icon: filters[indexPath.row].image, title: filters[indexPath.row].title)
        
        return cell
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let filterID = filters[indexPath.row].filterID
        
        delegate?.didSelectFilter(filterID)
        
        dismiss(animated: true)
    }
    
}
