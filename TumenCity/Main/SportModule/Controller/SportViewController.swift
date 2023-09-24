//
//  SportViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import YandexMapsMobile
import Combine
import RxSwift

class SportViewController: UIViewControllerMapSegmented {
    
    private let sportRegistryView: SportRegistryView
    private let sportRegistrySearchResult: SportRegistrySearchViewController
    
    private var timer: Timer?
    
    private let viewModel = SportViewModel()
    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    
    private let map = YandexMapView()
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
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
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getSportElements()
            }
        })
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
                
                map.mapView.moveCameraToAnnotation(latitude: lat, longitude: long)
            })
            .disposed(by: bag)
        
        sportRegistrySearchResult
            .selectedSportElementObservable
            .flatMap { [unowned self] sportElement in
                resetSegmentedControlAfterRegistryView()
                return viewModel.searchAnnotationByName(sportElement.title)
            }
            .sink { [unowned self] annotation in
                if let annotation{
                    map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    map.mapView.setDefaultRegion()
                }
            }
            .store(in: &cancellables)
        
        didChangeSearchController
            .subscribe(onNext: { [unowned self] _ in
                searchController.searchBar.rx.text.onCompleted()
                bindSearchController()
                print("che")
            })
            .disposed(by: bag)
        
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    private func bindSearchController() {
        searchController.searchBar.searchTextField
            .textPublisher
            .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .sink { [unowned self] str in
                print(str)
                viewModel.searchQuery = str
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink { [unowned self] in
                if $0 {
                    loadingViewController.showLoadingViewControllerIn(self)
                } else {
                    loadingViewController.removeLoadingViewControllerIn(self)
                }
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
        }
        
        viewModel
            .sportElementsObservable
            .sink { [unowned self] objects in
                collection.clear()
                viewModel.addSportAnnotations(objects: objects)
                sportRegistryView.sportElements = objects
                sportRegistrySearchResult.configure(sportElements: objects)
                sportRegistryView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel
            .sportAnnotationsObservable
            .sink { [unowned self] annotations in
                map.mapView.addAnnotations(annotations, cluster: collection)
            }
            .store(in: &cancellables)
        
        viewModel
            .$searchQuery
            .filter { [unowned self] _ in segmentedIndex == 0 }
            .flatMap { [unowned self] query in
                print(query)
                return viewModel.searchAnnotationByName(String(query))
            }
            .eraseToAnyPublisher()
            .sink { [unowned self] annotation in
                if let annotation{
                    map.mapView.moveCameraToAnnotation(annotation)
                } else {
                    map.mapView.setDefaultRegion()
                }
                
            }
            .store(in: &cancellables)
        
        viewModel
            .$searchQuery
            .filter { [unowned self] _ in segmentedIndex == 1 }
            .sink { [unowned self] query in
                sportRegistrySearchResult.filterSearch(with: query)
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKSportAnnotation else { return }
                let callout = SportCallout()
                callout.configure(annotation: annotation)
                callout.showAlert(in: self)
                
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
        cluster.addClusterTapListener(with: self)
    }
}

extension SportViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKSportAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            let bottomSheet = ClusterItemsListBottomSheet()
            bottomSheet.configureModal(annotations: annotations)
            setUpBindingsForTradeObjectsBottomSheet(for: bottomSheet)
            present(bottomSheet, animated: true)
            return true
        }
        
        return false
    }
}
