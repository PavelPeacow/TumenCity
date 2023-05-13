//
//  DigWorkBottomSheet.swift
//  TumenCity
//
//  Created by Павел Кай on 13.05.2023.
//

import UIKit

protocol DigWorkBottomSheetDelegate: AnyObject {
    func didTapAddress(_ annotation: MKDigWorkAnnotation)
}

final class DigWorkBottomSheet: CustomBottomSheet {
        
    var annotations = [MKDigWorkAnnotation]()
    
    weak var delegate: DigWorkBottomSheetDelegate?
    
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
        
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(25)
            $0.top.equalToSuperview().inset(topInset)
            $0.height.equalToSuperview().inset(topInset)
        }
                
        tableView.layoutIfNeeded()
        print(tableView.contentSize)
        
        var prefferedSize = tableView.contentSize.height + topInset * 2
        
        if prefferedSize > view.bounds.height / 2 {
            prefferedSize = view.bounds.height / 2 + topInset * 2
        }
        
        preferredContentSize = CGSize(width: view.bounds.width,
                                      height: prefferedSize)
        print(preferredContentSize)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func configureModal(annotations: [MKDigWorkAnnotation]) {
        self.annotations = annotations
    }
        
}

extension DigWorkBottomSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = annotations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
}

extension DigWorkBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let annotation = annotations[indexPath.row]
        delegate?.didTapAddress(annotation)
        dismiss(animated: true)
    }
    
}
