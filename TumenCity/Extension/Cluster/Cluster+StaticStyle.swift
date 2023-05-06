//
//  Cluster+StaticStyle.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import YandexMapsMobile

extension YMKPlacemarkMapObject {
    
    func setStaticImage(inClusterItemsCount: UInt, color: UIColor) {

        let bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let pieChartImage = renderer.image { _ in
            let startAngle: CGFloat = -.pi / 2
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = min(bounds.width, bounds.height) / 2

                let path = UIBezierPath()
                path.move(to: center)
                path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: 360, clockwise: true)
                path.close()
                
            let color = color
                color.setFill()
                path.fill()

 
            let centerPath = UIBezierPath(arcCenter: center, radius: radius / 1.5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
               UIColor.white.setFill()
               centerPath.fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            
            let text = "\(inClusterItemsCount)"
            let size = text.size(withAttributes: attributes)
            let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
            let rect = CGRect(origin: origin, size: size)
            text.draw(in: rect, withAttributes: attributes)
        }
        
        setIconWith(pieChartImage)
    }
    
}
