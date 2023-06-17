//
//  SportLabelView.swift
//  TumenCity
//
//  Created by Павел Кай on 07.05.2023.
//

import UIKit
import SnapKit

final class CalloutLabelView: UIView {
    
    lazy var calloutLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(label: String?) {
        super.init(frame: .zero)
        
        calloutLabel.text = label
        
        addSubview(calloutLabel)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 6
        
        calloutLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    convenience init() {
        self.init(label: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelWithDescription(_ description: String, label: String) {
        calloutLabel.text = "\(description) \(label)"
    }
    
}
