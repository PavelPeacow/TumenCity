//
//  SportViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

class SportViewController: UIViewControllerMapSegmented {
    
    private let sportRegistryView: SportRegistryView
    private let sportRegistrySearchResult: SportRegistrySearchViewController
    
    private var timer: Timer?
    
    private let viewModel = SportViewModel()
    private let bag = DisposeBag()
    
    private let map: YMKMapView = YandexMapMaker.makeYandexMap()
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var loadingViewController = LoadingViewController()
    
    init(sportRegistryView: SportRegistryView, sportRegistrySearchResult: SportRegistrySearchViewController) {
        self.sportRegistryView = sportRegistryView
        self.sportRegistrySearchResult = sportRegistrySearchResult
        
        super.init(mainMapView: map, registryView: sportRegistryView, registrySearchResult: sportRegistrySearchResult)
        super.addItemsToSegmentControll(["Карта", "Реестр"])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bindSearchController()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "Спорт"
        view.backgroundColor = .systemBackground
        
        sportRegistryView
            .selectedSportAddressObservable
            .subscribe(onNext: { [unowned self] address in
                resetSegmentedControlAfterRegistryView()
                
                guard case .double(let lat) = address.latitude else { return }
                guard case .double(let long) = address.longitude else { return }
                
                map.moveCameraToAnnotation(latitude: lat, longitude: long)
            })
            .disposed(by: bag)
        
        sportRegistrySearchResult
            .selectedSportElementObservable
            .flatMap { [unowned self] sportElement in
                resetSegmentedControlAfterRegistryView()
                return viewModel.searchAnnotationByName(sportElement.title)
            }
            .subscribe(onNext: { [unowned self] annotation in
                if let annotation{
                    map.moveCameraToAnnotation(annotation)
                } else {
                    map.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        didChangeSearchController
            .subscribe(onNext: { [unowned self] _ in
                searchController.searchBar.rx.text.onCompleted()
                bindSearchController()
                print("che")
            })
            .disposed(by: bag)
    }
    
    private func bindSearchController() {
        searchController.searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] str in
                viewModel.searchQuery.onNext(str)
            })
            .disposed(by: bag)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] in
                if $0 {
                    loadingViewController.showLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = true
                    }
                } else {
                    loadingViewController.removeLoadingViewControllerIn(self) { [unowned self] in
                        navigationItem.searchController?.searchBar.isHidden = false
                    }
                }
            })
            .disposed(by: bag)
        
        viewModel
            .sportElementsObservable
            .subscribe(
                onNext: { [unowned self] objects in
                    viewModel.addSportAnnotations(objects: objects)
                    sportRegistryView.sportElements = objects
                    sportRegistrySearchResult.configure(sportElements: objects)
                    sportRegistryView.tableView.reloadData()
                },
                onCompleted: { [unowned self] in
                    map.mapWindow.map.mapObjects.addTapListener(with: self)
                })
            .disposed(by: bag)
        
        viewModel
            .sportAnnotationsObservable
            .subscribe(onNext: { [unowned self] annotations in
                map.addAnnotations(annotations, cluster: collection)
            })
            .disposed(by: bag)
        
        viewModel
            .searchQuery
            .filter { [unowned self] _ in segmentedIndex == 0 }
            .flatMap { [unowned self] query in
                viewModel.searchAnnotationByName(query)
            }
            .subscribe(onNext: { [unowned self] annotation in
                if let annotation{
                    map.moveCameraToAnnotation(annotation)
                } else {
                    map.setDefaultRegion()
                }
            })
            .disposed(by: bag)
        
        viewModel
            .searchQuery
            .filter { [unowned self] _ in segmentedIndex == 1 }
            .subscribe(onNext: { [unowned self] query in
                sportRegistrySearchResult.filterSearch(with: query)
            })
            .disposed(by: bag)
    }
    
}

extension SportViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKSportAnnotation else { return false }
        
        let callout = SportCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
        return true
    }
    
}

extension SportViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
    }
    
}
