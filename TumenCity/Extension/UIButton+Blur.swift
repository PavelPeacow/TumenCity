//
//  UIButton+Blur.swift
//  TumenCity
//
//  Created by Павел Кай on 19.02.2023.
//

import UIKit

extension UIView {
    
    func setBlurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.isUserInteractionEnabled = false
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView, at: 0)
    }
}
