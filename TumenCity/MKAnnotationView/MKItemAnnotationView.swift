//
//  MKItemAnnotationView.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit

final class MKItemAnnotationView: MKAnnotationView {
    static let identifier = "MKItemAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? MKItemAnnotation else { return }
            
            image = annotation.image
            clusteringIdentifier = "MKItemAnnotationView"
            canShowCallout = true
            detailCalloutAccessoryView = AnnotationCalloutView(annotation: annotation)
        }
    }
}
