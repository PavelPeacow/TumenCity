//
//  YMKAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 17.06.2023.
//

import MapKit

protocol YMKAnnotation {
    var icon: UIImage { get }
    var coordinates: CLLocationCoordinate2D { get }
}
