//
//  CityCleaningViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

class CityCleaningViewController: UIViewController {
    
    private let viewModel = CityCleaningViewModel()
    private let bag = DisposeBag()
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var loadingController = LoadingViewController()
    private lazy var map = YandexMapMaker.makeYandexMap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(createToken())
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        YandexMapMaker.setYandexMapLayout(map: map, in: view)
        navigationItem.rightBarButtonItem = .init(image: .init(named: "filterIcon"),
                                                  style: .done, target: self, action: #selector(didTapFilter))
        collection.addTapListener(with: self)
    }
    
    private func setUpBindings() {
        viewModel
            .cityCleaningAnnotationsObservable
            .subscribe(onNext: { [unowned self] annotations in
                collection.clear()
                map.addAnnotations(annotations, cluster: collection)
            })
            .disposed(by: bag)
        
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                } else {
                    loadingController.removeLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            })
            .disposed(by: bag)
    }

}

extension CityCleaningViewController {
    
    @objc func didTapFilter() {
        let vc = CityCleaningFilterViewController()
        
        vc
            .selectedMachineTypesObservable
            .subscribe(onNext: { [unowned self] selectedMachineTypes in
                viewModel.filterAnnotationsByMachineType(type: selectedMachineTypes)
            })
            .disposed(by: bag)
        
        present(vc, animated: true)
    }
    
}

extension CityCleaningViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCityCleaningAnnotation else { return false }
        let callout = CityCleaningCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension CityCleaningViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCityCleaningAnnotation }
        cluster.appearance.setStaticImage(inClusterItemsCount: UInt(annotations.count), color: .orange)
    }
    
}
