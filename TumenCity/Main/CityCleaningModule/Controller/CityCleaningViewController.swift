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
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var loadingController = LoadingViewController()
    private lazy var map = YandexMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(createToken())
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "Уборка города"
        view.backgroundColor = .systemBackground
        
        map.setYandexMapLayout(in: self.view)
        
        let filterButton = UIBarButtonItem(image: .init(named: "filterIcon"),
                                           style: .done, target: self, action: #selector(didTapFilter))
        let reloadButton = UIBarButtonItem(image: .init(systemName: "arrow.counterclockwise"),
                                           style: .done, target: self, action: #selector(didTapReload))
        navigationItem.rightBarButtonItems = [filterButton, reloadButton]
        collection.addTapListener(with: self)
    }
    
    private func setUpBindings() {
        viewModel
            .cityCleaningAnnotationsObservable
            .subscribe(onNext: { [unowned self] annotations in
                collection.clear()
                map.mapView.addAnnotations(annotations, cluster: collection)
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            ErrorSnackBar(errorDesciptrion: error.localizedDescription,
                          andShowOn: self.view)
            navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        }
        
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self)
                } else {
                    loadingController.removeLoadingViewControllerIn(self)
                }
            })
            .disposed(by: bag)
    }
    
}

extension CityCleaningViewController {
    
    @objc
    func didTapFilter() {
        let vc = CityCleaningFilterViewController()
        
        vc
            .selectedMachineTypesObservable
            .subscribe(onNext: { [unowned self] selectedMachineTypes in
                viewModel.filterAnnotationsByMachineType(type: selectedMachineTypes)
            })
            .disposed(by: bag)
        
        vc
            .selectedContractorsObservable
            .subscribe(onNext: { [unowned self] selectedContractors in
                viewModel.filterAnnotationsByContractors(contractors: selectedContractors)
            })
            .disposed(by: bag)
        
        present(vc, animated: true)
    }
    
    @objc
    func didTapReload() {
        Task {
            await viewModel.getCityCleaningItems()
        }
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
