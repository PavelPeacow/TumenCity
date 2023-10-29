//
//  BikePathsViewController.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit
import Combine

protocol BikePathsActionsHandable: LoadViewActionsHandable {
    func handleShowBikeLegendBottomSheet()
    func handleAddBikePolylines(polylines: [YMKPolyline : UIColor])
    func handleAddBikePolygons(polygons: [YMKPolygon : YMKPoint])
}

final class BikePathsViewController: UIViewController {
    enum Actions {
        case setLoading(isLoading: Bool)
        case showSnackbar(type: SnackBarView.SnackBarType)
        case showBikeLegendBottomSheet
        case addBikePolylines(polylines: [YMKPolyline : UIColor])
        case aAddBikePolygons(polygons: [YMKPolygon : YMKPoint])
    }
    
    // MARK: - Properties
    var actionsHandable: BikePathsActionsHandable?
    
    private let viewModel: BikePathsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var mapObjectsCollection = map.mapView.mapWindow.map.mapObjects.add()
    
    // MARK: - Views
    private lazy var map = YandexMapView()
    private lazy var loadingController = LoadingViewController()
    
    // MARK: - Init
    init(viewModel: BikePathsViewModel) {
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
        setUpBindings()
        setupNetworkReachability(becomeAvailable: {
            Task {
                await self.viewModel.getBikePathsData()
            }
        })
    }
    
    // MARK: - Setup
    private func setUpView() {
        title = L10n.BikePaths.title
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "info.square"),
                                                  style: .done, target: self, action: #selector(didTapBikeStatInfo))
        map.setYandexMapLayout(in: self.view)
    }
    
    // MARK: - Bindings
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink { [unowned self] isLoading in
                action(.setLoading(isLoading: isLoading))
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            self?.action(.showSnackbar(type: .error(error.localizedDescription)))
        }
        
        viewModel
            .mapObjectsObservable
            .sink { [unowned self] data in
                guard let data = data else { return }
                mapObjectsCollection.clear()
                action(.aAddBikePolygons(polygons: data.polygons))
                action(.addBikePolylines(polylines: data.polilines))
            }
            .store(in: &cancellables)
    }
}

// MARK: - ACtions
extension BikePathsViewController: ViewActionsInteractable {
    func action(_ action: Actions) {
        switch action {
            
        case .setLoading(let isLoading):
            actionsHandable?.handleSetLoading(isLoading)
        case .showSnackbar(let type):
            actionsHandable?.handleShowSnackbar(type: type)
        case .showBikeLegendBottomSheet:
            actionsHandable?.handleShowBikeLegendBottomSheet()
        case .addBikePolylines(let polylines):
            actionsHandable?.handleAddBikePolylines(polylines: polylines)
        case .aAddBikePolygons(let polygons):
            actionsHandable?.handleAddBikePolygons(polygons: polygons)
        }
    }
}

// MARK: - Actions handable
extension BikePathsViewController: BikePathsActionsHandable {
    func handleSetLoading(_ isLoading: Bool) {
        if isLoading {
            loadingController.showLoadingViewControllerIn(self)
        } else {
            loadingController.removeLoadingViewControllerIn(self)
        }
    }
    
    func handleShowSnackbar(type: SnackBarView.SnackBarType) {
        SnackBarView(type: type, andShowOn: self.view)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func handleShowBikeLegendBottomSheet() {
        let bikeLegendInfo = BikePathInfoBottomSheet()
        let bikeInfo = viewModel.bikeInfoLegendItems
        bikeLegendInfo.configure(bikeInfoItems: bikeInfo)
        present(bikeLegendInfo, animated: true)
    }
    
    func handleAddBikePolylines(polylines: [YMKPolyline : UIColor]) {
        polylines.forEach { polyline in
            let polylineCreated = mapObjectsCollection.addPolyline(with: polyline.key)
            polylineCreated.strokeWidth = 2.5
            polylineCreated.setStrokeColorWith(polyline.value)
        }
    }
    
    func handleAddBikePolygons(polygons: [YMKPolygon : YMKPoint]) {
        polygons.forEach { polygon in
            map.mapView.addPolygon(polygon.key,
                                   color: .clear, strokeColor: .systemGray, stroreWidth: 1,
                                   collection: mapObjectsCollection)
            
            map.mapView.mapWindow.map.mapObjects.addPlacemark(with: polygon.value, image: .init(named: "bikeInWork") ?? .actions)
        }
    }
}

// MARK: - Objs functions
extension BikePathsViewController {
    @objc func didTapBikeStatInfo() {
        action(.showBikeLegendBottomSheet)
    }
}
