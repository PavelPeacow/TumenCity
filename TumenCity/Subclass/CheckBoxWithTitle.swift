//
//  CheckBoxWithTitle.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit

final class CheckBoxWithTitle: UIView {
    
    var checkBoxFilterId: String!
    
    var didTapCheckBoxCallback: ((_ id: String, _ isChecked: Bool) -> ())?
    
    lazy var contentStacKView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkBox, checkBoxTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()
    
    lazy var checkBox: CheckBoxButton = {
        let checkBox = CheckBoxButton()
        checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        return checkBox
    }()
    
    lazy var checkBoxTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    init(title: String, checkBoxFilterId: String) {
        super.init(frame: .zero)
        
        checkBoxTitle.text = title
        self.checkBoxFilterId = checkBoxFilterId
        
        addSubview(contentStacKView)
        
        contentStacKView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkBox.snp.makeConstraints {
            $0.size.equalTo(25)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectCheckBox() {
        checkBox.isChecked = true
        didTapCheckBoxCallback?(checkBoxFilterId, true)
    }
    
    func unSelectCheckBox() {
        checkBox.isChecked = false
        didTapCheckBoxCallback?(checkBoxFilterId, false)
    }
    
}

extension CheckBoxWithTitle {
    
    @objc func didTapCheckBox() {
        checkBox.isChecked.toggle()
        didTapCheckBoxCallback?(checkBoxFilterId, checkBox.isChecked)
    }
    
}
