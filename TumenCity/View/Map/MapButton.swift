//
//  MapButton.swift
//  TumenCity
//
//  Created by Павел Кай on 06.10.2023.
//

import UIKit

final class MapButtonView: UIView {
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(action: Selector, systemImage: String) {
        super.init(frame: .zero)
        setupButtonView(action: action, systemImage: systemImage)
        setupConstaints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtonView(action: Selector, systemImage: String) {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        backgroundColor = .systemBackground.withAlphaComponent(0.9)
        
        button.addTarget(nil, action: action, for: .touchUpInside)
        button.setSFSymbol(pointSize: 28, systemName: systemImage)
        addSubview(button)
    }
}

private extension MapButtonView {
    func setupConstaints() {
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        layoutIfNeeded()
        layer.cornerRadius = button.bounds.size.width / 2
    }
}

private extension UIButton {
    func setSFSymbol(pointSize: CGFloat, systemName: String) {
        let sfImage = UIImage(systemName: systemName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize))
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        
        setImage(sfImage, for: .normal)
    }
}
