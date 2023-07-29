//
//  Cluster+TradeObjectsPieChart.swift
//  TumenCity
//
//  Created by Павел Кай on 29.07.2023.
//

import YandexMapsMobile

extension YMKPlacemarkMapObject {
    
    func setPieChart(clusterAnnotations: [MKTradeObjectAnnotation]) {

        let greenCount = clusterAnnotations.countPieChartElements(by: .activeTrade)
        let blueCount = clusterAnnotations.countPieChartElements(by: .freeTrade)
        
        let values: [CGFloat] = [greenCount, blueCount]
        let colors: [UIColor] = [.init(named: "green")!, .init(named: "blue")!]

        let bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))

        let totalValue = values.reduce(0, +)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let pieChartImage = renderer.image { _ in
            var startAngle: CGFloat = -.pi / 2
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = min(bounds.width, bounds.height) / 2
            
            for (index, value) in values.enumerated() {
                let endAngle = startAngle + 2 * .pi * (value / totalValue)
                
                let path = UIBezierPath()
                path.move(to: center)
                path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                path.close()
                
                let color = colors[index % colors.count]
                color.setFill()
                path.fill()
                
                startAngle = endAngle
            }
 
            let centerPath = UIBezierPath(arcCenter: center, radius: radius / 1.5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
               UIColor.white.setFill()
               centerPath.fill()
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            
            let text = "\(clusterAnnotations.count)"
            let size = text.size(withAttributes: attributes)
            let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
            let rect = CGRect(origin: origin, size: size)
            text.draw(in: rect, withAttributes: attributes)
        }
        
        setIconWith(pieChartImage)
    }
    
}

extension Sequence where Element == MKTradeObjectAnnotation {
    func countPieChartElements(by elementType: MKTradeObjectAnnotation.AnnotationType) -> CGFloat {
        let count = CGFloat(self.filter { $0.type == elementType }.count)
        return count
    }
}
