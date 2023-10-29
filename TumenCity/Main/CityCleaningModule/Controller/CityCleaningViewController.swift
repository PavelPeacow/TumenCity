//
//  CityCleaningViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 15.06.2023.
//

import UIKit
import YandexMapsMobile
import RxSwift

protocol CityCleaningActionsHandable: ViewActionBaseMapHandable {
    func handleFilterTap()
}

final class CityCleaningViewController: UIViewController {
    enum Actions {
        case setLoading(isLoading: Bool)
        case showCallout(annotation: YMKAnnotation)
        case clusterTap(annotations: [YMKAnnotation])
        case showSnackbar(type: SnackBarView.SnackBarType)
        case filterTap
        case addAnnotations(annotations: [YMKAnnotation])
    }
    
    var actionsHandable: CityCleaningActionsHandable?
    
    private let viewModel: CityCleaningViewModel
    private let bag = DisposeBag()
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    private lazy var loadingController = LoadingViewController()
    private lazy var map = YandexMapView()
    
    init(viewModel: CityCleaningViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(createToken())
        setUpView()
        setUpBindings()
        setUpNavigationBar()
    }
    
    private func setUpView() {
        title = L10n.CityCleaning.title
        view.backgroundColor = .systemBackground
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getCityCleaningItems()
            }
        }, becomeUnavailable: {
            self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        })
        
        map.setYandexMapLayout(in: self.view)
        collection.addTapListener(with: self)
    }
    
    private func setUpNavigationBar() {
        let filterButton = UIBarButtonItem(image: .init(named: "filterIcon"),
                                           style: .done, target: self, action: #selector(didTapFilter))
        let reloadButton = UIBarButtonItem(image: .init(systemName: "arrow.counterclockwise"),
                                           style: .done, target: self, action: #selector(didTapReload))
        navigationItem.rightBarButtonItems = [filterButton, reloadButton]
    }
    
    private func setUpBindings() {
        viewModel
            .cityCleaningAnnotationsObservable
            .subscribe(onNext: { [unowned self] annotations in
                collection.clear()
                action(.addAnnotations(annotations: annotations))
            })
            .disposed(by: bag)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .isLoadingObservable
            .subscribe(onNext: { [unowned self] isLoading in
                action(.setLoading(isLoading: isLoading))
            })
            .disposed(by: bag)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKCityCleaningAnnotation else { return }
                action(.showCallout(annotation: annotation))
            })
            .disposed(by: bag)
    }
}

// MARK: - Actions
extension CityCleaningViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .clusterTap(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .filterTap:
            actionsHandable?.handleFilterTap()
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        }
    }
}

// MARK: - Actions handable
extension CityCleaningViewController: CityCleaningActionsHandable {
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKCityCleaningAnnotation else { return }
        let callout = CityCleaningCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        let bottomSheet = ClusterItemsListBottomSheet()
        bottomSheet.configureModal(annotations: annotations)
        setUpBindingsForTradeObjectsBottomSheet(for: bottomSheet)
        present(bottomSheet, animated: true)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: self.view)
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
    }
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingController.showLoadingViewControllerIn(self)
        } else {
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleFilterTap() {
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
}

// MARK: - Objs functions
private extension CityCleaningViewController {
    @objc
    func didTapFilter() {
        action(.filterTap)
    }
    
    @objc
    func didTapReload() {
        Task {
            await viewModel.getCityCleaningItems()
        }
    }
}

// MARK: - Map Logic
extension CityCleaningViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKCityCleaningAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}

extension CityCleaningViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCityCleaningAnnotation }
        cluster.appearance.setStaticImage(inClusterItemsCount: UInt(annotations.count), color: .orange)
        cluster.addClusterTapListener(with: self)
    }
}

extension CityCleaningViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKCityCleaningAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            action(.clusterTap(annotations: annotations))
            return true
        }
        return false
    }
}
