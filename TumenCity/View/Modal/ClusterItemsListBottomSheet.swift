//
//  DigWorkBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 13.05.2023.
//

import UIKit
import RxSwift

final class ClusterItemsListBottomSheet: CustomBottomSheet {
    
    private var annotations = [YMKAnnotation]()
    private var selectedAddress = PublishSubject<YMKAnnotation>()
    
    var selectedAddressObservable: Observable<YMKAnnotation> {
        selectedAddress
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setConstraints()
        setContentSize()
    }
    
    private func setUpView() {
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
    }
    
    private func setContentSize() {
        tableView.layoutIfNeeded()
        
        var prefferedSize = tableView.contentSize.height + topInset * 2
        if prefferedSize > view.bounds.height / 2 {
            prefferedSize = view.bounds.height / 2 + topInset * 2
        }
        
        preferredContentSize = CGSize(width: view.bounds.width,
                                      height: prefferedSize)
    }
    
    func configureModal(annotations: [YMKAnnotation]) {
        self.annotations = annotations
    }
    
}

private extension ClusterItemsListBottomSheet {
    
    func setConstraints() {
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
            $0.height.equalToSuperview().inset(topInset)
        }
    }
    
}

extension ClusterItemsListBottomSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = annotations[indexPath.row].title
        cell.imageView?.image = annotations[indexPath.row].icon
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
}

extension ClusterItemsListBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let annotation = annotations[indexPath.row]
        selectedAddress
            .onNext(annotation)
        dismiss(animated: true)
    }
    
}
