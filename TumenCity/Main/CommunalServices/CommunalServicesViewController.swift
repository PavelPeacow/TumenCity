//
//  ViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit
import MapKit

final class CommunalServicesViewController: UIViewController {
    
    let mainMapView = CommunalServicesView()
    let viewModel = CommunalServicesViewModel()
    
    override func loadView() {
        view = mainMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainMapView.map.setRegion(viewModel.setRegion(), animated: true)
        
        title = "Администрация города Тюмени"
        
        setDelegates()
    }
    
    private func setDelegates() {
        mainMapView.map.delegate = self
        viewModel.delegate = self
    }
    
    private func addServicesInfo() {
        guard let communalServices = viewModel.communalServices else { return }
        
        for serviceInfo in communalServices.info {
            let icon = UIImage(named: "filter-\(serviceInfo.id)") ?? .add
            let title = serviceInfo.title
            let count = String(serviceInfo.count)
            
            let serviceInfoView = ServiceInfoView(icon: icon, title: title, count: count, serviceType: serviceInfo.id)
            serviceInfoView.delegate = self
            
            mainMapView.servicesInfoStackView.addArrangedSubview(serviceInfoView)
        }
    }
    
}

extension CommunalServicesViewController: ServiceInfoViewDelegate {
    
    func didTapServiceInfoView(_ serviceType: Int, _ view: ServiceInfoView) {
        guard !view.isTapAlready else {
            mainMapView.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
            viewModel.resetFilterCommunalServices()
            return
        }
        
        mainMapView.servicesInfoStackView.arrangedSubviews.forEach { ($0 as? ServiceInfoView)?.isTapAlready = false }
        viewModel.filterCommunalServices(with: serviceType)
        view.isTapAlready = true
    }
    
}

extension CommunalServicesViewController: CommunalServicesViewModelDelegate {
    
    func didUpdateAnnotations(_ annotations: [MKItemAnnotation]) {
        let allAnnotations = mainMapView.map.annotations
        mainMapView.map.removeAnnotations(allAnnotations)
        
        mainMapView.map.addAnnotations(annotations)
    }
    
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation]) {
        mainMapView.map.addAnnotations(annotations)
        addServicesInfo()
    }
    
}

extension CommunalServicesViewController: MKMapViewDelegate {
    
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
                        
        } else if let annotation = view.annotation as? MKItemAnnotation {
            print(annotation.markDescription.address)
        }
    }
    
    
}
