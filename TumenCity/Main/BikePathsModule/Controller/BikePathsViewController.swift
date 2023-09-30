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

class BikePathsViewController: UIViewController {
    
    private let viewModel = BikePathsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var map = YandexMapView()
    private lazy var mapObjectsCollection = map.mapView.mapWindow.map.mapObjects.add()
    private lazy var loadingController = LoadingViewController()
    
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
    
    private func setUpView() {
        
        title = L10n.BikePaths.title
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "info.square"),
                                                  style: .done, target: self, action: #selector(didTapBikeStatInfo))
        map.setYandexMapLayout(in: self.view)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self)
                } else {
                    loadingController.removeLoadingViewControllerIn(self)
                }
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            SnackBarView(type: .error(error.localizedDescription),
                         andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel
            .mapObjectsObservable
            .sink { [unowned self] data in
                mapObjectsCollection.clear()
                data?.polygons.forEach { polygon in
                    map.mapView.addPolygon(polygon.key,
                                           color: .clear, strokeColor: .systemGray, stroreWidth: 1,
                                           collection: mapObjectsCollection)

                    _ = map.mapView.mapWindow.map.mapObjects.addPlacemark(with: polygon.value, image: .init(named: "bikeInWork")!)
                }
                
                data?.polilines.forEach { polyline in
                    let polylineCreated = mapObjectsCollection.addPolyline(with: polyline.key)
                    polylineCreated.strokeWidth = 2.5
                    polylineCreated.setStrokeColorWith(polyline.value)
                }
            }
            .store(in: &cancellables)
    }
    
}

extension BikePathsViewController {
    
    @objc func didTapBikeStatInfo() {
        let bikeLegendInfo = BikePathInfoBottomSheet()
        let bikeInfo = viewModel.bikeInfoLegendItems
        bikeLegendInfo.configure(bikeInfoItems: bikeInfo)
        present(bikeLegendInfo, animated: true)
    }
    
}
