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
    
    private lazy var collection = map.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    lazy var tradeObjectsFilterTypeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterViewFree, filterViewActive])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var filterViewFree: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterFree") ?? .add, filterTitle: Strings.TradeObjectsModule.filterFreeTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFreeFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    lazy var filterViewActive: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterActive") ?? .add, filterTitle: Strings.TradeObjectsModule.filterActiveTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapActiveFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    lazy var loadingController = LoadingViewController()
    lazy var loadingControllerForModal = LoadingViewController(type: .secondaryLoading)
    
    lazy var map = YandexMapMaker.makeYandexMap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "НТО"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tradeObjectsFilterTypeStackView)
        view.addSubview(map)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterIcon))
        
        tradeObjectsFilterTypeStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        YandexMapMaker.setYandexMapLayout(map: map, in: view) { [weak self] in
            guard let self else { return }
            $0.top.equalTo(self.tradeObjectsFilterTypeStackView.snp.bottom).offset(5)
        }
        map.mapWindow.map.mapObjects.addTapListener(with: self)
    }
#warning("Refactore rxswift code")
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink(receiveValue: { [unowned self] isLoading in
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
            .store(in: &cancellables)
            
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            ErrorSnackBar(errorDesciptrion: error.localizedDescription,
                          andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel
            .currentVisibleTradeObjectsAnnotationsObservable
            .dropFirst()
            .sink { [unowned self] annotations in
                collection.clear()
                map.addAnnotations(annotations, cluster: collection)
                setTradeObjectsCount(from: annotations)
            }
            .store(in: &cancellables)
        
        viewModel
            .tradeObjectsAnnotationsObservable
            .sink { [unowned self] annotations in
                map.addAnnotations(annotations, cluster: collection)
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
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: TradeObjectsBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                Task {
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
        
        bottomSheet.configureFilters(tradeObjectsType: tradeObjectsType, tradeObjectsPeriod: tradeObjectsPeriod)
        present(bottomSheet, animated: true)
    }
    
    @objc func didTapFreeFilter(_ sender: UITapGestureRecognizer) {
        guard let freeFilterView = sender.view as? TradeObjectsTypeView else { return }
        
        if isAlreadyTapped(on: freeFilterView) { return }
        selectFilter(freeFilterView)
        
        let annotation = viewModel.filterAnnotationsByType(.freeTrade)
        collection.clear()
        map.addAnnotations(annotation, cluster: collection)
    }
    
    @objc func didTapActiveFilter(_ sender: UITapGestureRecognizer) {
        guard let activeFilterView = sender.view as? TradeObjectsTypeView else { return }
        
        if isAlreadyTapped(on: activeFilterView) { return }
        selectFilter(activeFilterView)
        
        let annotation = viewModel.filterAnnotationsByType(.activeTrade)
        collection.clear()
        map.addAnnotations(annotation, cluster: collection)
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
        map.addAnnotations(current, cluster: collection)
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
            loadingControllerForModal.showLoadingViewControllerIn(self) { [unowned self] in
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            if let result = await viewModel.getFilteredTradeObjectByFilter(searchFilter) {
                collection.clear()
                let annotations = viewModel.addAnnotations(tradeObjects: result)
                viewModel.currentVisibleTradeObjectsAnnotations = annotations
            }
            loadingControllerForModal.removeLoadingViewControllerIn(self) { [unowned self] in
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
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
        #warning("4 annotations wrong coordinates")
        if viewModel.isClusterWithTheSameCoordinates(annotations: annotations) {
            let bottomSheet = TradeObjectsBottomSheet()
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
