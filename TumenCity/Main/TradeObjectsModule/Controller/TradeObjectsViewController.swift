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

protocol TradeObjectsActionsHandable: ViewActionBaseMapHandable {
    func handleTapFilterBottomSheet()
    func handleSetTradeObjectsCount(from annotations: [MKTradeObjectAnnotation])
    func handleSearchTradeObjects(search: TradeObjectsSearch)
    func handleResetSearch()
    func handleTapFilter(type: MKTradeObjectAnnotation.AnnotationType, fitlerView: TradeObjectsTypeView)
}

final class TradeObjectsViewController: UIViewController {
    enum Actions {
        case setLoading(isLoading: Bool)
        case tapCluster(annotations: [YMKAnnotation])
        case showCallout(annotation: YMKAnnotation)
        case tapFilterBottomSheet
        case showSnackbar(type: SnackBarView.SnackBarType)
        case addAnootations(annotations: [YMKAnnotation])
        case setTradeObjectsCount(annotations: [MKTradeObjectAnnotation])
        case searchTradeObjects(search: TradeObjectsSearch)
        case resetSearch
        case tapFilter(type: MKTradeObjectAnnotation.AnnotationType, fitlerView: TradeObjectsTypeView)
    }
    
    // MARK: - Properties
    var actionsHandable: TradeObjectsActionsHandable?
    
    private let viewModel: TradeObjectsViewModel
    
    private var currentTappedFilter: TradeObjectsTypeView?
    
    private var cancellables = Set<AnyCancellable>()
    private  let bag = DisposeBag()
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    // MARK: - Views
    private lazy var tradeObjectsFilterTypeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterViewFree, filterViewActive])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var filterViewFree: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterFree") ?? .add, filterTitle: L10n.TradeObjects.Callout.filterFreeTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFreeFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    private lazy var filterViewActive: TradeObjectsTypeView = {
        let filter = TradeObjectsTypeView(icon: .init(named: "filterActive") ?? .add, filterTitle: L10n.TradeObjects.Callout.filterActiveTitle)
        let filterFreeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapActiveFilter))
        filter.addGestureRecognizer(filterFreeGesture)
        return filter
    }()
    
    private lazy var loadingController = LoadingViewController()
    private lazy var loadingControllerForModal = LoadingViewController(type: .secondaryLoading)
    
    private lazy var map = YandexMapView()
    
    //MARK: - Init
    init(viewModel: TradeObjectsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpMap()
        setUpNavBar()
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getTradeObjectsData()
            }
        })
    }
    
    // MARK: - Setup
    private func setUpView() {
        title = L10n.TradeObjects.title
        view.backgroundColor = .systemBackground
        view.addSubview(tradeObjectsFilterTypeStackView)
        
        tradeObjectsFilterTypeStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func setUpNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(named: "filterIcon"), style: .done, target: self, action: #selector(didTapFilterIcon))
    }
    
    private func setUpMap() {
        map.setYandexMapLayout(in: view) { [weak self] in
            guard let self else { return }
            $0.top.equalTo(tradeObjectsFilterTypeStackView.snp.bottom).offset(5)
        }
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    // MARK: - Setup bindings
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink(receiveValue: { [unowned self] isLoading in
                action(.setLoading(isLoading: isLoading))
            })
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .currentVisibleTradeObjectsAnnotationsObservable
            .dropFirst()
            .sink { [unowned self] annotations in
                addAnnotations(annotations)
            }
            .store(in: &cancellables)
        
        viewModel
            .tradeObjectsAnnotationsObservable
            .sink { [unowned self] annotations in
                addAnnotations(annotations)
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindingsForTradeObjectsBottomSheet(for modal: ClusterItemsListBottomSheet) {
        modal
            .selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                action(.showCallout(annotation: annotation))
            })
            .disposed(by: bag)
    }
    
    // MARK: - Functions
    private func addAnnotations(_ annotations: [MKTradeObjectAnnotation]) {
        collection.clear()
        action(.addAnootations(annotations: annotations))
        action(.setTradeObjectsCount(annotations: annotations))
    }
}

// MARK: - Actions
extension TradeObjectsViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .tapCluster(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .tapFilterBottomSheet:
            actionsHandable?.handleTapFilterBottomSheet()
        case .addAnootations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .setTradeObjectsCount(let annotations):
            actionsHandable?.handleSetTradeObjectsCount(from: annotations)
        case .searchTradeObjects(let search):
            actionsHandable?.handleSearchTradeObjects(search: search)
        case .resetSearch:
            actionsHandable?.handleResetSearch()
        case .tapFilter(let type, let fitlerView):
            actionsHandable?.handleTapFilter(type: type, fitlerView: fitlerView)
        }
    }
}

// MARK: - Actinos handable
extension TradeObjectsViewController: TradeObjectsActionsHandable {
    func handleSetTradeObjectsCount(from annotations: [MKTradeObjectAnnotation]) {
        let count = annotations.map({ $0.type })
        let freeCount = count.filter({ $0 == .freeTrade }).count
        let activeCount = count.filter({ $0 == .activeTrade }).count
        
        filterViewFree.changeFilterCount(freeCount)
        filterViewActive.changeFilterCount(activeCount)
    }
    
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKTradeObjectAnnotation else { return }
        loadingControllerForModal.showLoadingViewControllerIn(self)
        Task {
            guard let tradeObject = await viewModel.getTradeObjectById(annotation.id) else { return }
            guard let item = tradeObject.row.first else { return }
            
            let modal = TradeObjectCallout()
            modal.configure(tradeObject: item, image: annotation.icon, type: annotation.type)
            modal.showAlert(in: self)
            loadingControllerForModal.removeLoadingViewControllerIn(self)
        }
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
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingController.showLoadingViewControllerIn(self)
        } else {
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: view)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleTapFilterBottomSheet() {
        let bottomSheet = TradeObjectsFilterBottomSheet()
        bottomSheet.delegate = self
        
        let tradeObjectsType = viewModel.tradeObjectsType
        let tradeObjectsPeriod = viewModel.tradeObjectsPeriod
        let suggestions = viewModel.tradeObjectsAnnotations.map { $0.address }
        
        bottomSheet.configureFilters(tradeObjectsType: tradeObjectsType, tradeObjectsPeriod: tradeObjectsPeriod, suggestions: suggestions)
        present(bottomSheet, animated: true)
    }
    
    func handleTapFilter(type: MKTradeObjectAnnotation.AnnotationType, fitlerView: TradeObjectsTypeView) {
        if isAlreadyTapped(on: fitlerView) { return }
        selectFilter(fitlerView)
        
        let annotation = viewModel.filterAnnotationsByType(type)
        collection.clear()
        map.mapView.addAnnotations(annotation, cluster: collection)
    }
    
    func handleSearchTradeObjects(search: TradeObjectsSearch) {
        Task {
            loadingController.showLoadingViewControllerIn(self)
            if let result = await viewModel.getFilteredTradeObjectByFilter(search) {
                collection.clear()
                let annotations = viewModel.addAnnotations(tradeObjects: result)
                viewModel.currentVisibleTradeObjectsAnnotations = annotations
            }
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleResetSearch() {
        collection.clear()
        let defaultAnnotations = viewModel.getDefualtTradeAnnotations()
        viewModel.currentVisibleTradeObjectsAnnotations = defaultAnnotations
    }
}

// MARK: - Objs functions
private extension TradeObjectsViewController {
    @objc func didTapFilterIcon() {
        action(.tapFilterBottomSheet)
    }
    
    @objc func didTapFreeFilter(_ sender: UITapGestureRecognizer) {
        guard let activeFilterView = sender.view as? TradeObjectsTypeView else { return }
        action(.tapFilter(type: .freeTrade, fitlerView: activeFilterView))
    }
    
    @objc func didTapActiveFilter(_ sender: UITapGestureRecognizer) {
        guard let activeFilterView = sender.view as? TradeObjectsTypeView else { return }
        action(.tapFilter(type: .activeTrade, fitlerView: activeFilterView))
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
        action(.addAnootations(annotations: current))
    }
    
    func selectFilter(_ filter: TradeObjectsTypeView) {
        currentTappedFilter?.isTappedFilterView = false
        currentTappedFilter = filter
        
        currentTappedFilter?.isTappedFilterView = true
    }
}

// MARK: - Delegate
extension TradeObjectsViewController: TradeObjectsFilterBottomSheetDelegate {
    func didTapSubmitBtn(_ searchFilter: TradeObjectsSearch) {
        action(.searchTradeObjects(search: searchFilter))
    }
    
    func didTapClearBtn() {
        action(.resetSearch)
    }
}

// MARK: - Map logic
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
            action(.tapCluster(annotations: annotations))
            return true
        }
        
        return false
    }
}

extension TradeObjectsViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKTradeObjectAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}
