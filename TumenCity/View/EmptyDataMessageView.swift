//
//  EmptyDataMessageView.swift
//  TumenCity
//
//  Created by Павел Кай on 21.09.2023.
//

import UIKit

final class EmptyDataMessageView: UIView {
    lazy var emptyMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет доступных данных"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .systemGray6
        layer.cornerRadius = 16
        
        addSubview(emptyMessageLabel)

        emptyMessageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
