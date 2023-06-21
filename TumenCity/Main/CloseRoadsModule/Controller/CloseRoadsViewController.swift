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

final class CloseRoadsViewController: UIViewController {
    
    private let viewModel = CloseRoadsViewModel()
    private let bag = DisposeBag()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    private lazy var loadingView = LoadingView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
        view.addSubview(loadingView)
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
                onNext: { [unowned self] objects in
                    self.viewModel.createCloseRoadAnnotation(objects: objects)
                },
                onError: { [unowned self] in
                    self.showErrorAlert(title: "Ошибка", description: $0.localizedDescription)
                }
            )
            .disposed(by: bag)
        
        viewModel
            .roadAnnotationsObserable
            .subscribe(
                onNext: { [unowned self] roadAnnotations in
                self.map.addAnnotations(roadAnnotations, cluster: self.collection)
            },
            onCompleted: { [unowned self] in
                self.map.mapWindow.map.mapObjects.addTapListener(with: self)
            })
            .disposed(by: bag)
        
        viewModel
            .roadPolygonsObserable
            .subscribe(onNext: { [unowned self] roadPolygons in
                roadPolygons.forEach { polygon in
                    self.map.addPolygon(polygon, color: .red.withAlphaComponent(0.15))
                }
            })
            .disposed(by: bag)
    }
    
}

extension CloseRoadsViewController: YMKClusterListener {
    
#warning("Probably contains annotaions with the same coordinates")
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
