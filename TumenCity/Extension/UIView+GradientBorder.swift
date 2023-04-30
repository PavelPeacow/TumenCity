//
//  UIView+GradientBorder.swift
//  TumenCity
//
//  Created by Павел Кай on 30.04.2023.
//

import UIKit

fileprivate extension UIImage {
    
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor).reversed()

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }
    }
    
}

extension UIView {
    
    func addGradientBorder(bounds: CGRect, colors: [UIColor]) {
        let image = UIImage.gradientImage(bounds: bounds, colors: colors)
        layer.borderColor = UIColor(patternImage: image).cgColor
    }
    
}
