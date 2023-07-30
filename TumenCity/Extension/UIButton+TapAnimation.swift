//
//  UIButton+TapAnimation.swift
//  TumenCity
//
//  Created by Павел Кай on 30.07.2023.
//

import UIKit

extension UIButton {
    func addTapAnimation() {
        addTarget(self, action: #selector(animateButtonTapped), for: [.touchUpInside, .touchDragInside])
    }

    @objc private func animateButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.alpha = 1.0
            }
        }
    }
}
