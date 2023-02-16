//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import MapKit

final class MainMapViewController: UIViewController {
    
    let viewModel = MainMapViewModel()
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.register(MKItemAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKItemAnnotationView.identifier)
        map.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.identifier)
        map.setRegion(viewModel.setRegion(), animated: true)
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(map)
                
        setDelegates()
        setConstraints()
    }
    
    private func setDelegates() {
        map.delegate = self
        viewModel.delegate = self
    }
    
}

extension MainMapViewController: MainMapViewModelDelegate {
    
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation]) {
        map.addAnnotations(annotations)
    }
    
}

extension MainMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
            
        case is MKItemAnnotation:
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKItemAnnotationView.identifier, for: annotation)
            
        case is MKClusterAnnotation:
            return mapView.dequeueReusableAnnotationView(withIdentifier: ClusterAnnotationView.identifier, for: annotation)
            
        default:
            return nil
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let sight = view.annotation as! MKItemAnnotation
        print(sight)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cluster = view.annotation as? MKClusterAnnotation {
            
            let annotations = cluster.memberAnnotations
            annotations.forEach { print($0.coordinate) }
            
            mapView.showAnnotations(cluster.memberAnnotations, animated: true)
        }
    }
    
    
}

extension MainMapViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}
