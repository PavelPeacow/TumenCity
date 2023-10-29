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

protocol DigWorkActionsHandable: ViewActionBaseMapHandable, ViewActionMoveCameraToAnnotationHandable {
    func handleShowFilterBottomSheet()
}

final class DigWorkViewController: UIViewController {
    enum Actions {
        case moveCameraToAnnotation(annotation: YMKAnnotation?)
        case showCallout(annotation: YMKAnnotation)
        case setLoading(isLoading: Bool)
        case addAnnotations(annotations: [YMKAnnotation])
        case showSnackbar(type: SnackBarView.SnackBarType)
        case clusterTap(annotations: [YMKAnnotation])
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
        
        map.setYandexMapLayout(in: view) {
            $0.top.equalTo(self.searchTextfield.snp.bottom).offset(5)
        }
        map.mapView.mapWindow.map.mapObjects.addTapListener(with: self)
        
        searchTextfield.setupTextfieldLayoutIn(view: view)
        suggestionTableView.setupSuggestionTableViewInView(view, topConstraint: {
            $0.top.equalTo(searchTextfield.snp.bottom)
        })
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
                    suggestionTableView.action(.hideTableSuggestions)
                    return
                }
                viewModel.searchQuery = str
                suggestionTableView.action(.showTableSuggestions)
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
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel.onEmptyResult = { [weak self] in
            self?.action(.showSnackbar(type: .warning(L10n.SnackBar.warning)))
        }
        
        viewModel
            .searchQueryObservable
            .sink { [unowned self] query in
                suggestionTableView.action(.search(query: query))
                let annotation = viewModel.findAnnotationByAddressName(query)
                action(.moveCameraToAnnotation(annotation: annotation))
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
                let annotation = viewModel.findAnnotationByAddressName(text)
                action(.moveCameraToAnnotation(annotation: annotation))
            })
            .disposed(by: bag)
        
        searchTextfield
            .didClearTextPublisher
            .sink { [unowned self] in
                suggestionTableView.action(.hideTableSuggestions)
            }
            .store(in: &cancellables)
    }
    
    private func configureModalSubscription(for modal: ClusterItemsListBottomSheet, with annotations: [YMKAnnotation]) {
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
            actionsHandable?.handleSetLoading(isLoading)
        case .addAnnotations(let annotations):
            actionsHandable?.handleAddAnnotations(annotations)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .clusterTap(let annotations):
            actionsHandable?.handleTapCluster(annotations: annotations)
        case .showFilterBottomSheet:
            actionsHandable?.handleShowFilterBottomSheet()
        case .moveCameraToAnnotation(annotation: let annotation):
            actionsHandable?.handleMoveToAnnotation(annotation: annotation)
        }
    }
}

// MARK: - Actions Handable
extension DigWorkViewController: DigWorkActionsHandable {
    func handleShowCallout(annotation: YMKAnnotation) {
        guard let annotation = annotation as? MKDigWorkAnnotation else { return }
        let callout = DigWorkCallout()
        callout.configure(annotation: annotation)
        callout.showAlert(in: self)
    }
    
    func handleTapCluster(annotations: [YMKAnnotation]) {
        let modal = ClusterItemsListBottomSheet()
        configureModalSubscription(for: modal, with: annotations)
        modal.configureModal(annotations: annotations)
        present(modal, animated: true)
    }
    
    func handleAddAnnotations(_ annotations: [YMKAnnotation]) {
        map.mapView.addAnnotations(annotations, cluster: collection)
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        if case .error = type {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        SnackBarView(type: type, andShowOn: self.view)
    }
    
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingViewController.showLoadingViewControllerIn(self)
        } else {
            loadingViewController.removeLoadingViewControllerIn(self)
        }
    }

    func handleMoveToAnnotation(annotation: YMKAnnotation?) {
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
