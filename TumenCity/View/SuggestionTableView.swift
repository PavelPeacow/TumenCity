//
//  SuggestionTableView.swift
//  TumenCity
//
//  Created by Павел Кай on 08.10.2023.
//

import UIKit
import Combine
import RxSwift
import SnapKit

protocol SuggestionTableViewActionsHandable {
    func handleShowTableSuggestions()
    func handleHideTableSuggestions()
    func handleSearch(_ query: String)
}

final class SuggestionTableView: UIView {
    enum Actions {
        case showTableSuggestions
        case hideTableSuggestions
        case search(query: String)
    }
    
    // MARK: - Properties
    var actionsHandable: SuggestionTableViewActionsHandable?
    
    private let suggestions = BehaviorSubject<[String]>(value: [])
    private let filteredSuggestions = BehaviorSubject<[String]>(value: [])
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let selectedSuggestion = PublishSubject<String>()
    var selectedSuggestionObservable: Observable<String> {
        selectedSuggestion.asObservable()
    }
    
    private lazy var bag = DisposeBag()
    
    // MARK: - Views
    private lazy var suggestionTableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        return tableView
    }()
    
    private lazy var emptyDataMessageView: EmptyDataMessageView = {
        let view = EmptyDataMessageView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
        setupBindings()
        setupConstaints()
        actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        addSubview(suggestionTableView)
        suggestionTableView.addSubview(emptyDataMessageView)
        
        tableViewHeightConstraint = suggestionTableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        Observable.combineLatest(filteredSuggestions, suggestions)
            .map { filteredElements, allElements in
                self.emptyDataMessageView.isHidden = !filteredElements.isEmpty
                return filteredElements
            }
            .bind(to: suggestionTableView.rx.items(cellIdentifier: "cell")) { (row, element, cell) in
                cell.textLabel?.text = element
                cell.backgroundColor = .systemGray5
                cell.textLabel?.numberOfLines = 0
            }
            .disposed(by: bag)
        
        suggestionTableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [unowned self] text in
                selectedSuggestion
                    .onNext(text)
                action(.hideTableSuggestions)
            })
            .disposed(by: bag)
        
        suggestionTableView.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] contentSize in
                guard let contentSize else { return }
                if contentSize.height < 200 && contentSize.height != 0 {
                    self?.tableViewHeightConstraint?.constant = contentSize.height
                } else {
                    self?.tableViewHeightConstraint?.constant = 200
                }
                if let sug = try? self?.filteredSuggestions.value(), sug.isEmpty {
                    self?.tableViewHeightConstraint?.constant = 100
                }
            })
            .disposed(by: bag)
    }
    
    // MARK: Functions
    func configure(suggestions: [String]) {
        let suggestions = suggestions.filter { !$0.isEmpty }
        self.suggestions.onNext(suggestions)
        self.filteredSuggestions.onNext(suggestions)
        suggestionTableView.reloadData()
    }
    
    func setupSuggestionTableViewInView(_ view: UIView, topConstraint: (ConstraintMaker) -> Void) {
        snp.makeConstraints {
            topConstraint($0)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
        }
        view.bringSubviewToFront(self)
    }
}

// MARK: - Actions
extension SuggestionTableView: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .showTableSuggestions:
            actionsHandable?.handleShowTableSuggestions()
        case .hideTableSuggestions:
            actionsHandable?.handleHideTableSuggestions()
        case .search(let query):
            actionsHandable?.handleSearch(query)
        }
    }
}

// MARK: - Actions handable
extension SuggestionTableView: SuggestionTableViewActionsHandable {
    func handleShowTableSuggestions() {
        isHidden = false
    }
    
    func handleHideTableSuggestions() {
        isHidden = true
    }
    
    func handleSearch(_ query: String) {
        suggestions
            .map { elements in
                elements.filter { $0.lowercased().contains(query.lowercased()) }
            }
            .bind(to: filteredSuggestions)
            .disposed(by: bag)
    }
}

private extension SuggestionTableView {
    func setupConstaints() {
        suggestionTableView.snp.makeConstraints {
            $0.top.equalTo(snp.top)
            $0.width.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        emptyDataMessageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
