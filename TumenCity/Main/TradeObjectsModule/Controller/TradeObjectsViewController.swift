//
//  TradeObjectsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit
import YandexMapsMobile
import Combine
import RxSwift

class TradeObjectsViewController: UIViewController {
    
    let viewModel = TradeObjectsViewModel()
    
    var currentTappedFilter: TradeObjectsTypeView?
    
    var cancellables = Set<AnyCancellable>()
    let bag = DisposeBag()
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var tradeObjectsFilterTypeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterViewFree, filterViewActive])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var filterViewFree: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterFree") ?? .add, filterTitle: L10n.TradeObjects.Callout.filterFreeTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFreeFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    lazy var filterViewActive: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterActive") ?? .add, filterTitle: L10n.TradeObjects.Callout.filterActiveTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapActiveFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    lazy var loadingController = LoadingViewController()
    lazy var loadingControllerForModal = LoadingViewController(type: .secondaryLoading)
    
    lazy var map = YandexMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        title = L10n.TradeObjects.title
        view.backgroundColor = .systemBackground
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getTradeObjectsData()
            }
        })
        
        view.addSubview(tradeObjectsFilterTypeStackView)
        
        map.setYandexMapLayout(in: view) { [weak self] in
            guard let self else { return }
            $0.top.equalTo(tradeObjectsFilterTypeStackView.snp.bottom).offset(5)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterIcon))
        
        tradeObjectsFilterTypeStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
#warning("Refactore rxswift code")
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink(receiveValue: { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self)
                } else {
                    loadingController.removeLoadingViewControllerIn(self)
                }
            })
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel
            .currentVisibleTradeObjectsAnnotationsObservable
            .dropFirst()
            .sink { [unowned self] annotations in
                collection.clear()
                map.mapView.addAnnotations(annotations, cluster: collection)
                setTradeObjectsCount(from: annotations)
            }
            .store(in: &cancellables)
        
        viewModel
            .tradeObjectsAnnotationsObservable
            .sink { [unowned self] annotations in
                collection.clear()
                map.mapView.addAnnotations(annotations, cluster: collection)
                setTradeObjectsCount(from: annotations)
            }
            .store(in: &cancellables)
    }
    
    private func setTradeObjectsCount(from annotations: [MKTradeObjectAnnotation]) {
        let count = annotations.map({ $0.type })
        let freeCount = count.filter({ $0 == .freeTrade }).count
        let activeCount = count.filter({ $0 == .activeTrade }).count
        
        filterViewFree.changeFilterCount(freeCount)
        filterViewActive.changeFilterCount(activeCount)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                Task {
                    guard let annotation = annotation as? MKTradeObjectAnnotation else { return }
                    if let detailInfo = await viewModel.getTradeObjectById(annotation.id), let object = detailInfo.row.first {
                        let callout = TradeObjectCallout()
                        callout.configure(tradeObject: object, image: annotation.icon, type: annotation.type)
                        callout.showAlert(in: self)
                    }
                }
            })
            .disposed(by: bag)
    }
    
}

private extension TradeObjectsViewController {
    
    @objc func didTapFilterIcon() {
        let bottomSheet = TradeObjectsFilterBottomSheet()
        bottomSheet.delegate = self
        
        let tradeObjectsType = viewModel.tradeObjectsType
        let tradeObjectsPeriod = viewModel.tradeObjectsPeriod
        let suggestions = viewModel.tradeObjectsAnnotations.map { $0.address }
        
        bottomSheet.configureFilters(tradeObjectsType: tradeObjectsType, tradeObjectsPeriod: tradeObjectsPeriod, suggestions: suggestions)
        present(bottomSheet, animated: true)
    }
    
    @objc func didTapFreeFilter(_ sender: UITapGestureRecognizer) {
        guard let freeFilterView = sender.view as? TradeObjectsTypeView else { return }
        
        if isAlreadyTapped(on: freeFilterView) { return }
        selectFilter(freeFilterView)
        
        let annotation = viewModel.filterAnnotationsByType(.freeTrade)
        collection.clear()
        map.mapView.addAnnotations(annotation, cluster: collection)
    }
    
    @objc func didTapActiveFilter(_ sender: UITapGestureRecognizer) {
        guard let activeFilterView = sender.view as? TradeObjectsTypeView else { return }
        
        if isAlreadyTapped(on: activeFilterView) { return }
        selectFilter(activeFilterView)
        
        let annotation = viewModel.filterAnnotationsByType(.activeTrade)
        collection.clear()
        map.mapView.addAnnotations(annotation, cluster: collection)
    }
    
    func isAlreadyTapped(on view: TradeObjectsTypeView) -> Bool {
        if currentTappedFilter != nil, currentTappedFilter == view {
            resetSelectedFilter()
            return true
        }
        return false
    }
    
    func resetSelectedFilter() {
        currentTappedFilter?.isTappedFilterView = false
        currentTappedFilter = nil
        
        collection.clear()
        let current = viewModel.getCurrentVisibleTradeAnnotations()
        map.mapView.addAnnotations(current, cluster: collection)
    }
    
    func selectFilter(_ filter: TradeObjectsTypeView) {
        currentTappedFilter?.isTappedFilterView = false
        currentTappedFilter = filter
        
        currentTappedFilter?.isTappedFilterView = true
    }
    
}

extension TradeObjectsViewController: TradeObjectsFilterBottomSheetDelegate {
    
    func didTapSubmitBtn(_ searchFilter: TradeObjectsSearch) {
        Task {
            loadingController.showLoadingViewControllerIn(self)
            if let result = await viewModel.getFilteredTradeObjectByFilter(searchFilter) {
                collection.clear()
                let annotations = viewModel.addAnnotations(tradeObjects: result)
                viewModel.currentVisibleTradeObjectsAnnotations = annotations
            }
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func didTapClearBtn() {
        collection.clear()
        let defaultAnnotations = viewModel.getDefualtTradeAnnotations()
        viewModel.currentVisibleTradeObjectsAnnotations = defaultAnnotations
    }
    
}

extension TradeObjectsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKTradeObjectAnnotation }
        cluster.appearance.setPieChart(clusterAnnotations: annotations)
        cluster.addClusterTapListener(with: self)
    }
    
}

extension TradeObjectsViewController: YMKClusterTapListener {
    
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKTradeObjectAnnotation }
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

extension TradeObjectsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKTradeObjectAnnotation else { return false }
        loadingControllerForModal.showLoadingViewControllerIn(self)
        Task {
            guard let tradeObject = await viewModel.getTradeObjectById(annotation.id) else { return }
            guard let item = tradeObject.row.first else { return }
            
            let modal = TradeObjectCallout()
            modal.configure(tradeObject: item, image: annotation.icon, type: annotation.type)
            modal.showAlert(in: self)
            loadingControllerForModal.removeLoadingViewControllerIn(self)
        }
        
        return true
    }
    
}
