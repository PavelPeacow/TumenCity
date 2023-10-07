//
//  YandexMapUserLocationManager.swift
//  TumenCity
//
//  Created by Павел Кай on 06.10.2023.
//

import YandexMapsMobile

final class YandexMapUserLocationManager: NSObject {
    private var userLocationLayer: YMKUserLocationLayer?
    
    var updatedLocation: ((YMKCameraPosition?) -> Void)?
    
    override init() { }
    
    private func goToSetting() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    func createUserLocationLayer(mapWindow: YMKMapWindow) {
        let mapKit = YMKMapKit.sharedInstance()
        userLocationLayer = mapKit.createUserLocationLayer(with: mapWindow)
        userLocationLayer?.setVisibleWithOn(true)
        userLocationLayer?.setObjectListenerWith(self)
    }
    
    func getUserPosition() -> YMKCameraPosition? {
        userLocationLayer?.cameraPosition()
    }
    
    func requestUserLocationAgain() -> UIAlertController {
        let alert = UIAlertController(
            title: "Включите местоположение!",
            message: "Для отслеживания вашего местоположения на карте, необходимо перейти в настройки приложения",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Перейти в настройки", style: .default, handler: { [weak self] _ in
            self?.goToSetting()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        return alert
    }
}

extension YandexMapUserLocationManager: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named: "userLocation")!,
                               style:YMKIconStyle(
                                anchor: nil,
                                rotationType: YMKRotationType.noRotation.rawValue as NSNumber,
                                zIndex: 2,
                                flat: nil,
                                visible: true,
                                scale: 1.5,
                                tappableArea: nil))
        
        let pinPlacemark = view.pin.useCompositeIcon()
        
        pinPlacemark.setIconWithName("icon",
                                     image: UIImage(named: "userLocation")!,
                                     style:YMKIconStyle(
                                        anchor: nil,
                                        rotationType: YMKRotationType.noRotation.rawValue as NSNumber,
                                        zIndex: 2,
                                        flat: nil,
                                        visible: true,
                                        scale: 1.5,
                                        tappableArea: nil))
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) { }
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) { }
}
