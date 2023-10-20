//
//  DigWorkViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit
import RxSwift
import Combine

protocol DigWorkActionsHandable {
    func handleShowCallout(annotation: MKDigWorkAnnotation)
    func handleSetLoading(isLoading: Bool)
    func handleAddAnnotations(_ annotations: [MKDigWorkAnnotation])
    func handleShowSnackbarError(_ error: String)
    func handleShowSnackbarWarning(_ warning: String)
    func handleClusterTap(_ annotations: [MKDigWorkAnnotation])
    func handleMoveCameraToAnnotationByQuery(_ query: String)
    func handleShowFilterBottomSheet()
}

final class DigWorkViewController: UIViewController {
    enum Actions {
        case showCallout(annotation: MKDigWorkAnnotation)
        case setLoading(isLoading: Bool)
        case addAnnotations(annotations: [MKDigWorkAnnotation])
        case showSnackbarError(error: String)
        case handleShowSnackbarWarning(warning: String)
        case clusterTap(annotations: [MKDigWorkAnnotation])
        case moveCameraToAnnotationByQuery(query: String)
        case showFilterBottomSheet
    }
    
    // MARK: - Properties
    var actionsHandable: DigWorkActionsHandable?
    
    private let viewModel: DigWorkViewModel
    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collection = map.mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
    
    // MARK: - Views
    private lazy var searchTextfield: SearchTextField = {
        SearchTextField()
    }()
    private lazy var suggestionTableView: SuggestionTableView = {
        SuggestionTableView()
    }()
    private lazy var loadingViewController = LoadingViewController()
    private lazy var map = YandexMapView()
    
    // MARK: - Init
    init(viewModel: DigWorkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.actionsHandable = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpMap()
        setUpNavigationBar()
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getDigWorkElements()
            }
        })
    }
    
    // MARK: Setup
    private func setUpView() {
        title = L10n.DigWork.title
        view.backgroundColor = .systemBackground
        view.addSubview(suggestionTableView)
        view.addSubview(searchTextfield)
        
        searchTextfield.setupTextfieldLayoutIn(view: view)
        suggestionTableView.setupSuggestionTableViewInView(view, topConstraint: {
            $0.top.equalTo(searchTextfield.snp.bottom)
        })
    }
    
    private func setUpMap() {
        map.setYandexMapLayout(in: self.view) {
            $0.top.equalTo(self.searchTextfield.snp.bottom).offset(5)
        }
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
    }
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapFilterIcon))
    }
    
    // MARK: - Bindings
    private func bindSearchController() {
        searchTextfield
            .textPublisher
            .sink { [unowned self] str in
                guard str.count > 0 else {
                    suggestionTableView.hideTableSuggestions()
                    return
                }
                viewModel.searchQuery = str
                suggestionTableView.showTableSuggestions()
            }
            .store(in: &cancellables)
    }
    
    private func setUpBindings() {
        bindSearchController()
        
        viewModel
            .isLoadingObservable
            .sink { [unowned self] in
                action(.setLoading(isLoading: $0))
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbarError(error: error.localizedDescription))
        }
        
        viewModel.onEmptyResult = { [weak self] in
            self?.action(.handleShowSnackbarWarning(warning: L10n.SnackBar.warning))
        }
        
        viewModel
            .searchQueryObservable
            .sink { [unowned self] query in
                suggestionTableView.search(text: query)
                action(.moveCameraToAnnotationByQuery(query: query))
            }
            .store(in: &cancellables)
        
        viewModel
            .digWorkAnnotationsObservable
            .sink { [unowned self] annotations in
                collection.clear()
                action(.addAnnotations(annotations: annotations))
                suggestionTableView.configure(suggestions: annotations.map { $0.address })
            }
            .store(in: &cancellables)
        
        suggestionTableView
            .selectedSuggestionObservable
            .subscribe(onNext: { [unowned self] text in
                searchTextfield.resetTextfieldState()
                action(.moveCameraToAnnotationByQuery(query: text))
            })
            .disposed(by: bag)
        
        searchTextfield
            .didClearTextPublisher
            .sink { [unowned self] in
                suggestionTableView.hideTableSuggestions()
            }
            .store(in: &cancellables)
    }
    
    private func configureModalSubscription(for modal: ClusterItemsListBottomSheet, with annotations: [MKDigWorkAnnotation]) {
        modal.selectedAddressObservable
            .subscribe(onNext: { [unowned self] annotation in
                guard let annotation = annotation as? MKDigWorkAnnotation else { return }
                action(.showCallout(annotation: annotation))
            })
            .disposed(by: bag)
    }
    
}

// MARK: - Actions
extension DigWorkViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .showCallout(let annotation):
            actionsHandable?.handleShowCallout(annotation: annotation)
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading: isLoading)
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .showSnackbarError(let error):
            actionsHandable?.handleShowSnackbarError(error)
        case .handleShowSnackbarWarning(let warning):
            actionsHandable?.handleShowSnackbarWarning(warning)
        case .clusterTap(let annotations):
            actionsHandable?.handleClusterTap(annotations)
        case .moveCameraToAnnotationByQuery(let query):
            actionsHandable?.handleMoveCameraToAnnotationByQuery(query)
        case .showFilterBottomSheet:
            actionsHandable?.handleShowFilterBottomSheet()
        }
    }
}

// MARK: - Actions Handable
extension DigWorkViewController: DigWorkActionsHandable {
    func handleShowCallout(annotation: MKDigWorkAnnotation) {
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
    func handleSetLoading(isLoading: Bool) {
        if isLoading {
            loadingViewController.showLoadingViewControllerIn(self)
        } else {
            loadingViewController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleAddAnnotations(_ annotations: [MKDigWorkAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleShowSnackbarError(_ error: String) {
        SnackBarView(type: .error(error), andShowOn: self.view)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleShowSnackbarWarning(_ warning: String) {
        SnackBarView(type: .warning(warning), andShowOn: self.view)
    }
    
    func handleClusterTap(_ annotations: [MKDigWorkAnnotation]) {
        let modal = ClusterItemsListBottomSheet()
        configureModalSubscription(for: modal, with: annotations)
        modal.configureModal(annotations: annotations)
        present(modal, animated: true)
    }
    
    func handleMoveCameraToAnnotationByQuery(_ query: String) {
        let annotation = viewModel.findAnnotationByAddressName(query)
        if let annotation {
            map.mapView.moveCameraToAnnotation(annotation)
        } else {
            map.mapView.setDefaultRegion()
        }
    }
    
    func handleShowFilterBottomSheet() {
        let vc = DigWorkFilterBottomSheet()
        vc
            .selectedFilterObservable
            .subscribe(onNext: { [unowned self] filter in
                Task {
                    await viewModel.getDigWorkElements(filter: filter)
                }
            })
            .disposed(by: bag)
        
        vc
            .didDismissedObservable
            .subscribe(onNext: { [unowned self] in
                Task {
                    await viewModel.getDigWorkElements()
                }
            })
            .disposed(by: bag)
        present(vc, animated: true)
    }
}

// MARK: - Objc functions
private extension DigWorkViewController {
    @objc func didTapFilterIcon() {
        action(.showFilterBottomSheet)
    }
}

// MARK: - Map logic
extension DigWorkViewController: YMKClusterListener {
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setStaticImage(inClusterItemsCount: cluster.size, color: .green)
        cluster.addClusterTapListener(with: self)
    }
}

extension DigWorkViewController: YMKClusterTapListener {
    func onClusterTap(with cluster: YMKCluster) -> Bool {
        let annotations = cluster.placemarks.compactMap { $0.userData as? MKDigWorkAnnotation }
        if isClusterWithTheSameCoordinates(annotations: annotations) {
            action(.clusterTap(annotations: annotations))
        }
        return true
    }
}

extension DigWorkViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let annotation = mapObject.userData as? MKDigWorkAnnotation else { return false }
        action(.showCallout(annotation: annotation))
        return true
    }
}
