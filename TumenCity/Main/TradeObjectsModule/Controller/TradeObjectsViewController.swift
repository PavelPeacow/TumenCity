//
//  TradeObjectsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 20.05.2023.
//

import UIKit
import YandexMapsMobile

class TradeObjectsViewController: UIViewController {
    
    let viewModel = TradeObjectsViewModel()
    
    var currentTappedFilter: TradeObjectsTypeView?
    
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
    
    lazy var map = YandexMapMaker.makeYandexMap()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
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
    }
    
    private func setTradeObjectsCount(from annotations: [MKTradeObjectAnnotation]) {
        let count = annotations.map({ $0.type })
        let freeCount = count.filter({ $0 == .freeTrade }).count
        let activeCount = count.filter({ $0 == .activeTrade }).count
        
        filterViewFree.changeFilterCount(freeCount)
        filterViewActive.changeFilterCount(activeCount)
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
        
        viewModel.filterAnnotationsByType(.freeTrade)
    }
    
    @objc func didTapActiveFilter(_ sender: UITapGestureRecognizer) {
        guard let activeFilterView = sender.view as? TradeObjectsTypeView else { return }
        
        if isAlreadyTapped(on: activeFilterView) { return }
        selectFilter(activeFilterView)
        
        viewModel.filterAnnotationsByType(.activeTrade)
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
        map.addAnnotations(viewModel.currentVisibleTradeObjectsAnnotations, cluster: collection)
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
            if let result = await viewModel.getFilteredTradeObjectByFilter(searchFilter) {
                collection.clear()
                let annotations = viewModel.addAnnotations(tradeObjects: result)
                viewModel.currentVisibleTradeObjectsAnnotations = annotations
                map.addAnnotations(annotations, cluster: collection)
                setTradeObjectsCount(from: annotations)
            }
        }
    }
    
    func didTapClearBtn() {
        collection.clear()
        let annotations = viewModel.tradeObjectsAnnotations
        map.addAnnotations(annotations, cluster: collection)
        setTradeObjectsCount(from: annotations)
    }

}

extension TradeObjectsViewController: TradeObjectsViewModelDelegate {
    
    func didFinishAddingAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation]) {
        map.addAnnotations(tradeAnnotations, cluster: collection)
        map.mapWindow.map.mapObjects.addTapListener(with: self)
        
        setTradeObjectsCount(from: tradeAnnotations)
    }
    
    func didFilterAnnotations(_ tradeAnnotations: [MKTradeObjectAnnotation]) {
        collection.clear()
        
        map.addAnnotations(tradeAnnotations, cluster: collection)
    }
    
}

extension TradeObjectsViewController: YMKClusterListener {
    
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .blue)
    }
    
}

extension TradeObjectsViewController: YMKMapObjectTapListener {
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKTradeObjectAnnotation else { return false }
        
        Task {
            guard let tradeObject = await viewModel.getTradeObjectById(annotation.id) else { return }
            guard let item = tradeObject.row.first else { return }
            print(tradeObject.row.first)
            let modal = TradeObjectCallout()
            modal.configure(tradeObject: item, image: annotation.icon ?? .add, type: annotation.type)
            modal.showAlert(in: self)
        }
        
        return true
    }
    
}
