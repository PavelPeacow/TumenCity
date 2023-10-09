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

final class SuggestionTableView: UIView {
    private var suggestions = BehaviorSubject<[String]>(value: [])
    private var filteredSuggestions = BehaviorSubject<[String]>(value: [])
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var selectedSuggestion = PublishSubject<String>()
    var selectedSuggestionObservable: Observable<String> {
        selectedSuggestion.asObservable()
    }
    
    private lazy var bag = DisposeBag()
    
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
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupBindings()
        setupConstaints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        addSubview(suggestionTableView)
        suggestionTableView.addSubview(emptyDataMessageView)
        
        tableViewHeightConstraint = suggestionTableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }
    
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
                hideTableSuggestions()
            })
            .disposed(by: bag)
        
        suggestionTableView.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] contentSize in
                print(contentSize?.height)
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
    
    func search(text: String) {
        suggestions
            .map { elements in
                elements.filter { $0.lowercased().contains(text.lowercased()) }
            }
            .bind(to: filteredSuggestions)
            .disposed(by: bag)
    }
    
    func configure(suggestions: [String]) {
        let suggestions = suggestions.filter { !$0.isEmpty }
        self.suggestions.onNext(suggestions)
        self.filteredSuggestions.onNext(suggestions)
        suggestionTableView.reloadData()
    }
    
    func showTableSuggestions() {
        isHidden = false
    }
    
    
    func hideTableSuggestions() {
        isHidden = true
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
