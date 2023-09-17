//
//  ErrorSnackBar.swift
//  TumenCity
//
//  Created by Павел Кай on 16.09.2023.
//

import UIKit

final class ErrorSnackBar: UIView {
    // MARK: Properties
    private enum Constants {
        static let paddingConstant = 16
        static let paddingTitles = 4
        
        static let appearingTime = 0.5
        static let disappearingTime = appearingTime + 4.0
    }
    
    private let errorDesciptrion: String
    private let parentView: UIView
    
    private lazy var errorTitleLabel = UILabel()
    
    // MARK: Lifecycle
    @discardableResult
    init(errorDesciptrion: String, andShowOn parentView: UIView) {
        self.errorDesciptrion = errorDesciptrion
        self.parentView = parentView
        
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
extension ErrorSnackBar {
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemRed.withAlphaComponent(0.95)
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    private func setupGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapSnackBar))
        addGestureRecognizer(gesture)
    }
    
    private func setupErrorLabel() {
        errorTitleLabel.text = errorDesciptrion
        errorTitleLabel.numberOfLines = 0
        errorTitleLabel.textAlignment = .center
        errorTitleLabel.font = .preferredFont(forTextStyle: .callout)
        errorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(errorTitleLabel)
        errorTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.paddingConstant)
            $0.leading.trailing.equalToSuperview().inset(Constants.paddingConstant)
            $0.bottom.equalToSuperview().inset(Constants.paddingConstant)
        }
    }
}

extension ErrorSnackBar {
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
