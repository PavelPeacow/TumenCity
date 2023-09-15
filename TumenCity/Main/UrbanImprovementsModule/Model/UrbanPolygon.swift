//
//  UrbanPolygon.swift
//  TumenCity
//
//  Created by Павел Кай on 01.06.2023.
//

import UIKit

final class UrbanPolygon {
    
    let filterTypeID: Int
    let polygonColor: UIColor
    let id: Int
    let icon: UIImage
    
    init(filterTypeID: Int, polygonColor: UIColor, id: Int, icon: UIImage) {
        self.filterTypeID = filterTypeID
        self.polygonColor = polygonColor
        self.id = id
        self.icon = icon
    }
    
}
