//
//  UrbanImprovementsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 23.05.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

class UrbanImprovementsViewController: UIViewController {

    private let viewModel = UrbanImprovementsViewModel()
    private let bag = DisposeBag()
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    private var currentActiveFilterID: Int?
    
    private lazy var map = YandexMapMaker.makeYandexMap()
    private lazy var loadingController = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "Благоустройство"
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: view)
        navigationItem.rightBarButtonItem = .init(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterBtn))
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self) {
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                } else {
                    loadingController.removeLoadingViewControllerIn(self) {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            ErrorSnackBar(errorDesciptrion: error.localizedDescription,
                          andShowOn: self.view)
        }
        
        viewModel
            .mapObjectsObservable
            .subscribe(onNext: { [unowned self] pointsAnnotations, polygons in
                map.addAnnotations(pointsAnnotations, cluster: collection)
                collection.addTapListener(with: self)
                
                polygons.forEach { polygon in
                    map.addPolygon(polygon.0, polygonData: polygon.1, color: polygon.1.polygonColor.withAlphaComponent(0.5), tapListener: self)
                }
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForUrbanImprovementsFilterBottomSheet(for modal: UrbanImprovementsFilterBottomSheet) {
        modal
            .selectedFilterObservable
            .subscribe(onNext: { [unowned self] selectedFilterIndex in
                resetMap()
                
                let filteredAnnotations = viewModel.filterAnnotationsByFilterID(selectedFilterIndex)
                let filteredPolygons = viewModel.filterPolygonsByFilterID(selectedFilterIndex)
                
                map.addAnnotations(filteredAnnotations, cluster: collection)
                
                filteredPolygons.forEach { polygon in
                    map.addPolygon(polygon.0, polygonData: polygon.1, color: polygon.1.polygonColor.withAlphaComponent(0.5), tapListener: self)
                }
                
                currentActiveFilterID = selectedFilterIndex
            })
            .disposed(by: bag)
        
        modal
            .didDiscardFilterObservable
            .subscribe(onNext: { [unowned self] in
                resetMap()
                
                let annotations = viewModel.urbanAnnotations
                let polygons = viewModel.polygonsFormatted
                
                map.addAnnotations(annotations, cluster: collection)
                
                polygons.forEach { polygon in
                    map.addPolygon(polygon.0, polygonData: polygon.1, color: polygon.1.polygonColor.withAlphaComponent(0.5), tapListener: self)
                }
                
                currentActiveFilterID = nil
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForUrbanImprovementsBottomSheet(for modal: UrbanImprovementsBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                Task {
                    if let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(annotation.id) {
                        let callout = UrbanImprovementsCallout()
                        callout.configure(urbanDetailInfo: detailInfo, calloutImage: annotation.icon)
                        callout.showAlert(in: self)
                    }
                }
            })
            .disposed(by: bag)
    }
    
    private func resetMap() {
        map.mapWindow.map.mapObjects.clear()
        collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    }

}

extension UrbanImprovementsViewController {
    
    @objc func didTapFilterBtn() {
        let bottomSheet = UrbanImprovementsFilterBottomSheet()
        bottomSheet.configure(filters: viewModel.filterItems, currentActiveFilterID: currentActiveFilterID)
        setUpBindingsForUrbanImprovementsFilterBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
    
}

extension UrbanImprovementsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
        cluster.addClusterTapListener(with: self)
    }
    
}

extension UrbanImprovementsViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKUrbanAnnotation }
        guard viewModel.isClusterWithTheSameCoordinates(annotations: annotations) else { return false }
        
        let bottomSheet = UrbanImprovementsBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        setUpBindingsForUrbanImprovementsBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
        
        return true
    }
    
}

extension UrbanImprovementsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let polygon = mapObject as? YMKPolygonMapObject {
            guard let polygonData = polygon.userData as? UrbanPolygon else { return false }
            print(polygonData.filterTypeID)
            
            Task {
                if let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(polygonData.id) {
                    let callout = UrbanImprovementsCallout()
                    callout.configure(urbanDetailInfo: detailInfo, calloutImage: polygonData.icon)
                    callout.showAlert(in: self)
                    return true
                }
                return false
            }
            
            return true
        }
        
        if let point = mapObject as? YMKPlacemarkMapObject {
            guard let annotation = point.userData as? MKUrbanAnnotation else { return false }
            print(annotation)
            
            Task {
                if let detailInfo = await viewModel.getUrbanImprovementsDetailInfoByID(annotation.id) {
                    let callout = UrbanImprovementsCallout()
                    callout.configure(urbanDetailInfo: detailInfo, calloutImage: annotation.icon)
                    callout.showAlert(in: self)
                    return true
                }
                return false
            }
           
        }
        
        return false
    }
    
}
