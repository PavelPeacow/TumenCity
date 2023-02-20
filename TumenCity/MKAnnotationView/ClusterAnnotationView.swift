//
//  ClusterAnnotationView.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit

final class ClusterAnnotationView: MKAnnotationView {
    
    static let identifier = "ClusterAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        updateImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return }
            
            displayPriority = .required
            
            if isClusterWithTheSameCoordinates() {
                canShowCallout = true
                detailCalloutAccessoryView = ClusterCalloutView(cluster: clusterAnnotation)
            } else {
                canShowCallout = false
            }
            
            updateImage()
        }
    }
    
    
    private func isClusterWithTheSameCoordinates() -> Bool {
        guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return false }
        guard let annotations = clusterAnnotation.memberAnnotations as? [MKItemAnnotation] else { return false }
        return annotations.dropFirst().allSatisfy( { $0.coordinate.latitude == annotations.first?.coordinate.latitude } )
    }
    
    private func updateImage() {
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            self.image = image(clusterAnnotation: clusterAnnotation)
        }
    }
    
    func image(clusterAnnotation: MKClusterAnnotation) -> UIImage? {
        guard let clusterMembers = clusterAnnotation.memberAnnotations as? [MKItemAnnotation] else { return nil }
        
        let coldCount = clusterMembers.coldCount
        let hotCount = clusterMembers.hotCount
        let otopCount = clusterMembers.otopCount
        let electroCount = clusterMembers.electroCount
        let gazCount = clusterMembers.gazCount
        
        let values: [CGFloat] = [otopCount.count, hotCount.count, coldCount.count, electroCount.count, gazCount.count]
        let colors: [UIColor] = [otopCount.color, hotCount.color, coldCount.color, electroCount.color, gazCount.color]

        let bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))

        let totalValue = values.reduce(0, +)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
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
 
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]
            
            let text = "\(clusterMembers.count)"
            let size = text.size(withAttributes: attributes)
            let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
            let rect = CGRect(origin: origin, size: size)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
    
}

extension Sequence where Element == MKItemAnnotation {
    var coldCount: (count: CGFloat, color: UIColor) {
        let count = CGFloat(self.filter { $0.markType == .cold }.count)
        let color = self.first(where: { $0.markType == .cold })?.color ?? .white
        return (count, color)
    }
    
    var hotCount: (count: CGFloat, color: UIColor) {
        let count = CGFloat(self.filter { $0.markType == .hot }.count)
        let color = self.first(where: { $0.markType == .hot })?.color ?? .white
        return (count, color)
    }
    
    var otopCount: (count: CGFloat, color: UIColor) {
        let count = CGFloat(self.filter { $0.markType == .otop }.count)
        let color = self.first(where: { $0.markType == .otop })?.color ?? .white
        return (count, color)
    }
    
    var electroCount: (count: CGFloat, color: UIColor) {
        let count = CGFloat(self.filter { $0.markType == .electro }.count)
        let color = self.first(where: { $0.markType == .electro })?.color ?? .white
        return (count, color)
    }
    
    var gazCount: (count: CGFloat, color: UIColor) {
        let count = CGFloat(self.filter { $0.markType == .gaz }.count)
        let color = self.first(where: { $0.markType == .gaz })?.color ?? .white
        return (count, color)
    }
}
