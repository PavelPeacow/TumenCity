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
            displayPriority = .defaultHigh
            updateImage()
        }
    }
    
    private func updateImage() {
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            self.image = image(count: clusterAnnotation.memberAnnotations.count)
        } else {
            self.image = image(count: 1)
        }
    }

    func image(count: Int) -> UIImage {
        let bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            UIBezierPath(ovalIn: bounds).fill()

            UIColor.white.setFill()
            UIBezierPath(ovalIn: bounds.insetBy(dx: 8, dy: 8)).fill()

            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]

            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
            let rect = CGRect(origin: origin, size: size)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
    
}
