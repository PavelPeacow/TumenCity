//
//  CloseRoadsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 03.05.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift
import RxCocoa

class CloseRoadsViewController: UIViewController {
    
    private let viewModel = CloseRoadsViewModel()
    private let bag = DisposeBag()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    private lazy var loadingView = LoadingView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
        view.addSubview(loadingView)
        
        setUpBindings()
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObserable
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.isLoadingSubject)
            .disposed(by: bag)
        
        viewModel
            .closeRoadsObserable
            .subscribe(
                onNext: {
                    $0.forEach { object in
                        self.viewModel.createCloseRoadAnnotation(object: object)
                    }
                },
                onError: {
                    self.showErrorAlert(title: "Ошибка", description: $0.localizedDescription)
                }
            )
            .disposed(by: bag)
        
        viewModel
            .roadAnnotationsObserable
            .subscribe(onNext: { [weak self] roadAnnotations in
                guard let self = self else { return }
                self.map.addAnnotations(roadAnnotations, cluster: self.collection)
                self.map.mapWindow.map.mapObjects.addTapListener(with: self)
            })
            .disposed(by: bag)
        
        viewModel
            .roadPolygonsObserable
            .subscribe(onNext: { [weak self] roadPolygons in
                guard let self = self else { return }
                roadPolygons.forEach { polygon in
                    self.map.addPolygon(polygon, color: .red.withAlphaComponent(0.15))
                }
            })
            .disposed(by: bag)
    }
    
}

extension CloseRoadsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCloseRoadAnnotation }
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .red)
    }
    
}

extension CloseRoadsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCloseRoadAnnotation else { return false }
        
        let callout = CloseRoadCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}
