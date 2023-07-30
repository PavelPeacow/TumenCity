//
//  UICollectionViewCell+Animation.swift
//  TumenCity
//
//  Created by Павел Кай on 30.07.2023.
//

import UIKit

extension UICollectionViewCell {
    func tapAnimation() {
        let originalBackgroundColor = backgroundColor
        let originalTransform = transform

        let targetBackgroundColor = UIColor.systemBlue
        let scaleTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = targetBackgroundColor
            self.transform = scaleTransform
        }) { (completed) in
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = originalBackgroundColor
                self.transform = originalTransform
            }
        }
    }
}
