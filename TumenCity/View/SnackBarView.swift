//
//  ErrorSnackBar.swift
//  TumenCity
//
//  Created by Павел Кай on 16.09.2023.
//

import UIKit

final class SnackBarView: UIView {
    // MARK: Properties
    private enum Constants {
        static let paddingConstant = 16
        static let paddingTitles = 4
        
        static let appearingTime = 0.5
        static let disappearingTime = appearingTime + 4.0
    }
    
    enum SnackBarType {
        case error(String)
        case warning(String)
        
        case noConnection
        case withConnection
    }
    
    private var type: SnackBarType
    private let parentView: UIView
    
    private lazy var snackBarLabel = UILabel()
    
    // MARK: Lifecycle
    @discardableResult
    init(type: SnackBarType, andShowOn parentView: UIView) {
        self.parentView = parentView
        self.type = type
        
        super.init(frame: .zero)
        guard parentView.subviews.firstIndex(where: { $0 is Self }) == nil else { return }
        setupView()
        setupGesture()
        setupErrorLabel()
        showErrorSnackBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    private func showErrorSnackBar() {
        parentView.addSubview(self)
        
        snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(parentView.snp.bottomMargin).inset(-200)
        }
        animateAppearingAndDissapearing()
    }
        
    private func animateAppearingAndDissapearing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.appearingTime) {
            self.snp.updateConstraints {
                $0.bottom.equalTo(self.parentView.snp.bottomMargin).inset(30)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.parentView.layoutIfNeeded()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.disappearingTime)  { [self] in
            self.snp.updateConstraints {
                $0.bottom.equalTo(parentView.snp.bottomMargin).inset(-200)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.parentView.layoutIfNeeded()
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: - Setup
extension SnackBarView {
    private func setupView() {
        snackBarLabel.text = ""
        translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .error(let error):
            backgroundColor = .systemRed.withAlphaComponent(0.95)
            snackBarLabel.text = error
        case .warning(let warning):
            backgroundColor = .systemYellow.withAlphaComponent(0.95)
            snackBarLabel.text = warning
            
        case .noConnection:
            backgroundColor = .systemRed.withAlphaComponent(0.95)
            snackBarLabel.text = L10n.SnackBar.noConnection
        case .withConnection:
            backgroundColor = .systemGreen.withAlphaComponent(0.95)
            snackBarLabel.text = L10n.SnackBar.withConnection
        }
        
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    private func setupGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapSnackBar))
        addGestureRecognizer(gesture)
    }
    
    private func setupErrorLabel() {
        snackBarLabel.numberOfLines = 0
        snackBarLabel.textAlignment = .center
        snackBarLabel.font = .preferredFont(forTextStyle: .callout)
        snackBarLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(snackBarLabel)
        snackBarLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.paddingConstant)
            $0.leading.trailing.equalToSuperview().inset(Constants.paddingConstant)
            $0.bottom.equalToSuperview().inset(Constants.paddingConstant)
        }
    }
}

extension SnackBarView {
    @objc
    func didTapSnackBar() {
        snp.updateConstraints {
            $0.bottom.equalTo(parentView.snp.bottomMargin).inset(-200)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.parentView.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
