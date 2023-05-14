//
//  DigWorkViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit

class DigWorkViewController: UIViewController {
    
    private let viewModel = DigWorkViewModel()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Введите адрес..."
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    lazy var map: YMKMapView = {
        let map = YMKMapView()
        map.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        map.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 20, verticalPadding: 50*2))
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        map.setDefaultRegion()
        
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterIcon))
        view.addSubview(map)
        
        setConstraints()
    }
    
}

extension DigWorkViewController {
    
    @objc func didTapFilterIcon() {
        let vc = DigWorkFilterBottomSheet()
        present(vc, animated: true)
    }
    
}

extension DigWorkViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}

extension DigWorkViewController: DigWorkViewModelDelegate {
    
    func didFinishAddingAnnotations(_ annotations: [MKDigWorkAnnotation]) {
        map.addAnnotations(annotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
}

extension DigWorkViewController: DigWorkBottomSheetDelegate {
    
    func didTapAddress(_ annotation: MKDigWorkAnnotation) {
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
}

extension DigWorkViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
        cluster.addClusterTapListener(with: self)
    }
    
}

extension DigWorkViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKDigWorkAnnotation }

        annotations.forEach { print($0.coordinates) }
        annotations.forEach { print($0.title) }
        
        if viewModel.isClusterWithTheSameCoordinates(annotations: annotations) {
            let modal = DigWorkBottomSheet()
            modal.delegate = self
            modal.configureModal(annotations: annotations)
            present(modal, animated: true)
        }
        
        return true
    }
    
}

extension DigWorkViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKDigWorkAnnotation else { return false }
        
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension DigWorkViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            map.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
}
