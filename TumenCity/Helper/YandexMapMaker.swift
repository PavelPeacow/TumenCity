//
//  MapMakeHelper.swift
//  TumenCity
//
//  Created by Павел Кай on 19.05.2023.
//

import Foundation
import YandexMapsMobile
import SnapKit

final class YandexMapMaker {
    
    private init() { }
    
    static func makeYandexMap() -> YMKMapView {
        let map = YMKMapView()
        map.mapWindow.map.logo.setAlignmentWith(.init(horizontalAlignment: .left, verticalAlignment: .bottom))
        map.mapWindow.map.logo.setPaddingWith(.init(horizontalPadding: 20, verticalPadding: 50*2))
        map.translatesAutoresizingMaskIntoConstraints = false
        map.setDefaultRegion()
        return map
    }
    
    static func setYandexMapLayout(map: YMKMapView, in view: UIView, withPaddingFrom: ((ConstraintMaker) -> Void)? = nil) {
        if let paddingForm = withPaddingFrom {
            map.snp.makeConstraints {
                paddingForm($0)
            }
        } else {
            map.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        map.snp.makeConstraints {
            $0.width.equalTo(view).multipliedBy(1)
            $0.bottom.equalTo(view)
        }
    }
    
}
