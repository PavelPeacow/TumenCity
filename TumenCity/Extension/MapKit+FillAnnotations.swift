//
//  MapKit+FillAnnotations.swift
//  TumenCity
//
//  Created by Павел Кай on 20.02.2023.
//

import MapKit

extension MKMapView {
    
    func fitAllAnnotations() {
        guard !annotations.isEmpty else { return }
        var zoomRect = MKMapRect.null;
        
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
}
