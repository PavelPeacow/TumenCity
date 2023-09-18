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
    
    private lazy var map: YMKMapView = YandexMapMaker.makeYandexMap()
    private lazy var loadingController = LoadingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpView() {
        title = "Велодорожки"
        view.addSubview(map)
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "info.square"),
                                                  style: .done, target: self, action: #selector(didTapBikeStatInfo))
        YandexMapMaker.setYandexMapLayout(map: map, in: self.view)
    }
    
    private func setUpBindings() {
        viewModel
            .isLoadingObservable
            .sink { [unowned self] isLoading in
                if isLoading {
                    loadingController.showLoadingViewControllerIn(self) {
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                } else {
                    loadingController.removeLoadingViewControllerIn(self) {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            ErrorSnackBar(errorDesciptrion: error.localizedDescription,
                          andShowOn: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        viewModel
            .mapObjectsObservable
            .sink { [unowned self] data in
                data?.polygons.forEach { polygon in
                    let polygonCreated = map.mapWindow.map.mapObjects.addPolygon(with: polygon.key)
                    polygonCreated.strokeWidth = 1
                    polygonCreated.strokeColor = .systemGray
                    polygonCreated.fillColor = .clear
                    
                    _ = map.mapWindow.map.mapObjects.addPlacemark(with: polygon.value, image: .init(named: "bikeInWork")!)
                }
                
                data?.polilines.forEach { polyline in
                    let polylineCreated = map.mapWindow.map.mapObjects.addPolyline(with: polyline.key)
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
