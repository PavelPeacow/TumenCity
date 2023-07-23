//
//  UrbanImprovementsFilterBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import UIKit
import RxSwift

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
        stackView.distribution = .fill
        stackView.alignment = .center
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
            $0.top.equalToSuperview().inset(0)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(25)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        filterIcon.snp.makeConstraints {
            $0.size.equalTo(35)
        }
        
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        containerView.backgroundColor = .systemGray6
    }
    
    func configureCell(icon: UIImage?, title: String) {
        filterIcon.image = icon
        filterTitle.text = title
    }
    
}

final class UrbanImprovementsFilterBottomSheet: CustomBottomSheet {
    
    private var filters = [UrbanFilter]()
    private var currentActiveFilterID: Int?
    
    private let selectedFilter = PublishSubject<Int>()
    private let didDiscardFilter = PublishSubject<Void>()
    
    var selectedFilterObservable: Observable<Int> {
        selectedFilter.asObservable()
    }
    var didDiscardFilterObservable: Observable<Void> {
        didDiscardFilter.asObservable()
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [discardFilterBtn, tableView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var discardFilterBtn: MainButton = {
        let btn = MainButton(title: "Отменить фильтр", cornerRadius: 12)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(didTapDiscardBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UrbanImprovementsFilterCell.self, forCellReuseIdentifier: UrbanImprovementsFilterCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpConstaints()
    }
    
    private func setUpView() {
        view.addSubview(stackView)
        view.backgroundColor = .systemBackground
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.height / 2)
    }
    
    func configure(filters: [UrbanFilter], currentActiveFilterID: Int?) {
        self.filters = filters
        
        if let currentActiveFilterID {
            discardFilterBtn.isHidden = false
            self.currentActiveFilterID = currentActiveFilterID
        }
    }
    
}

private extension UrbanImprovementsFilterBottomSheet {
    
    func setUpConstaints() {
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
            $0.height.equalToSuperview().inset(topInset)
        }
    }
    
}

extension UrbanImprovementsFilterBottomSheet {
    
    @objc func didTapDiscardBtn() {
        didDiscardFilter
            .onNext(())
        dismiss(animated: true)
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UrbanImprovementsFilterCell.identifier, for: indexPath) as! UrbanImprovementsFilterCell
        
        if filters[indexPath.row].filterID == currentActiveFilterID ?? -1 {
            cell.containerView.backgroundColor = .systemBlue
        }
        
        cell.configureCell(icon: filters[indexPath.row].image, title: filters[indexPath.row].title)
        
        return cell
    }
    
}

extension UrbanImprovementsFilterBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let filterID = filters[indexPath.row].filterID
        selectedFilter
            .onNext(filterID)
        
        dismiss(animated: true)
    }
    
}
