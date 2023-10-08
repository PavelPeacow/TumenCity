//
//  SearchTextfield.swift
//  TumenCity
//
//  Created by Павел Кай on 30.09.2023.
//

import UIKit
import Combine

final class SearchTextField: UITextField {
    private var didClearText = PassthroughSubject<Void, Never>()
    
    var didClearTextPublisher: AnyPublisher<Void, Never> {
        didClearText.eraseToAnyPublisher()
    }

    private lazy var searchIcon: UIImageView = {
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        return searchIcon
    }()
    
    private lazy var searchIconContainerView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    }()
    
    private lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        return clearButton
    }()
    
    private lazy var clearIconContainerView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    }()
    
    init() {
        super.init(frame: .zero)
        placeholder = L10n.SearchTextfield.placeholder
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        
        searchIconContainerView.addSubview(searchIcon)
        leftView = searchIconContainerView
        leftViewMode = .always
        
        clearIconContainerView.addSubview(clearButton)
        rightView = clearIconContainerView
        rightViewMode = .whileEditing
        
        delegate = self
        
        addTarget(self, action: #selector(didBegin), for: .editingDidBegin)

        backgroundColor = .systemGray5
        textColor = .label
        font = .systemFont(ofSize: 16)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextfieldLayoutIn(view: UIView) {
        snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func resetTextfieldState() {
        resignFirstResponder()
        text = ""
    }
}

private extension SearchTextField {
    @objc func clearText() {
        resetTextfieldState()
        didClearText.send(())
    }
    
    @objc func didBegin() {
        let originalSearchIconTransform = searchIcon.transform
        let scaleSearchIconTransform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        
        let originalClearButtonTransform = clearButton.transform
        let scaleClearButtonTransform = CGAffineTransform(scaleX: 1.35, y: 1.35)

        UIView.animate(withDuration: 0.2, animations: {
            self.searchIcon.transform = scaleSearchIconTransform
            self.clearButton.transform = scaleClearButtonTransform
        }) { (completed) in
            UIView.animate(withDuration: 0.2) {
                self.searchIcon.transform = originalSearchIconTransform
                self.clearButton.transform = originalClearButtonTransform
            }
        }
    }
}

extension SearchTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
