//
//  YandexMapView.swift
//  TumenCity
//
//  Created by Павел Кай on 19.05.2023.
//

import Foundation
import YandexMapsMobile
import SnapKit

final class YandexMapView: UIView {
    private lazy var locationManager: YandexMapUserLocationManager = {
        YandexMapUserLocationManager()
    }()
    
    lazy var mapView: YMKMapView = {
        let view = YMKMapView()
        view.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 25, verticalPadding: 10))
        view.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var defaultLocationButtonView: MapButtonView = {
        MapButtonView(action: #selector(didTapDefaultLocationButton), systemImage: "map.fill")
    }()
    
    private lazy var personLocationButtonView: MapButtonView = {
        MapButtonView(action: #selector(didTapPersonLocationButton), systemImage: "location.fill")
    }()
        
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mapView.mapWindow.map.isNightModeEnabled = traitCollection.userInterfaceStyle == .dark ? true : false
    }
    
    private func setupView() {
        mapView.mapWindow.map.isNightModeEnabled = traitCollection.userInterfaceStyle == .dark ? true : false
        translatesAutoresizingMaskIntoConstraints = false
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 16
        clipsToBounds = true
        mapView.setDefaultRegion()
        
        locationManager.createUserLocationLayer(mapWindow: mapView.mapWindow)
        
        addSubview(mapView)
        addSubview(defaultLocationButtonView)
        addSubview(personLocationButtonView)
        
        defaultLocationButtonView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(25)
            $0.bottomMargin.equalToSuperview().inset(25)
            $0.size.equalTo(50)
        }
        
        personLocationButtonView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(25)
            $0.bottom.equalTo(defaultLocationButtonView).inset(75)
            $0.size.equalTo(50)
        }
    }
    
    func setYandexMapLayout(in view: UIView, withPaddingFrom: ((ConstraintMaker) -> Void)? = nil) {
        view.addSubview(self)
        
        if let paddingForm = withPaddingFrom {
            snp.makeConstraints {
                paddingForm($0)
            }
        } else {
            snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

private extension YandexMapView {
    @objc
    func didTapDefaultLocationButton() {
        mapView.setDefaultRegion()
    }
    
    @objc
    func didTapPersonLocationButton() {
        guard let userPosition = locationManager.getUserPosition()  else {
            if let viewController = UIApplication.shared.windows.last(where: { $0.isKeyWindow })?.rootViewController {
                let alert = locationManager.requestUserLocationAgain()
                viewController.present(alert, animated: true)
            }
            return
        }

        mapView.mapWindow.map.move(with: userPosition, animationType: .init(type: .smooth, duration: 0.35))
    }
}
