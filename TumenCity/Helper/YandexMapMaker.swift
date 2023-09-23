//
//  MapMakeHelper.swift
//  TumenCity
//
//  Created by Павел Кай on 19.05.2023.
//

import Foundation
import YandexMapsMobile
import SnapKit

final class YandexMapView: UIView {
    lazy var mapView: YMKMapView = {
        let view = YMKMapView()
        view.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 25, verticalPadding: 10))
        view.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var buttonBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground.withAlphaComponent(0.9)
        return view
    }()
    
    private lazy var defaultLocationButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapDefaultLocationButton), for: .touchUpInside)
        let sfImage = UIImage(systemName: "location.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 28))
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        
        button.setImage(sfImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        
        addSubview(mapView)
        addSubview(buttonBackgroundView)
        buttonBackgroundView.addSubview(defaultLocationButton)
        
        buttonBackgroundView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(25)
            $0.bottomMargin.equalToSuperview().inset(25)
            $0.size.equalTo(44)
        }
        
        defaultLocationButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buttonBackgroundView.layoutIfNeeded()
        buttonBackgroundView.layer.cornerRadius = buttonBackgroundView.bounds.size.width / 2
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
}
