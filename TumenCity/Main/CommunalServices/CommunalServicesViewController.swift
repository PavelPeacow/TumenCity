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
    var timer: Timer?
    
    lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        return search
    }()
    
    override func loadView() {
        view = mainMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainMapView.map.setDefaultRegion()
        
        title = "Отключение ЖКУ"
        
        registerKeyboardNotification()
        setUpSearchController()
        setDelegates()
    }
    
    private func setDelegates() {
        mainMapView.map.delegate = self
        viewModel.delegate = self
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите адресс..."
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
        
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardHeight = keyboardSize.height
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mainMapView.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.mainMapView.frame.origin.y = 0
        }
    }
    
}

extension CommunalServicesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        
        guard let searchText = searchController.searchBar.text else { return mainMapView.map.setDefaultRegion() }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            if let annotation = self?.viewModel.findAnnotationByAddressName(searchText) {
                self?.mainMapView.map.showAnnotations([annotation], animated: false)
                self?.mainMapView.map.deselectAnnotation(annotation, animated: false)
                self?.mainMapView.map.selectAnnotation(annotation, animated: true)
            } else {
                self?.mainMapView.map.setDefaultRegion()
            }
        })
        
        
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
        mainMapView.map.fitAllAnnotations()
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
            //fix flickiring, but decrease performance!
            return MKItemAnnotationView(annotation: annotation, reuseIdentifier: MKItemAnnotationView.identifier)
            
        case is MKClusterAnnotation:
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: ClusterAnnotationView.identifier)
            
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
