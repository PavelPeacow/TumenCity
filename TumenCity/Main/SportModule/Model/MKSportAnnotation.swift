//
//  MKSportAnnotation.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import MapKit
import YandexMapsMobile
import UIKit

final class MKSportAnnotation: YMKPoint {
    
    var icon: UIImage
    var title: String
    var coordinates: CLLocationCoordinate2D
    var contacts: Contacts
    var addresses: [Address]
    
    override var latitude: Double {
        coordinates.latitude.magnitude
    }
    
    override var longitude: Double {
        coordinates.longitude.magnitude
    }
    
    init(icon: UIImage, title: String, coordinates: CLLocationCoordinate2D, contacts: Contacts, addresses: [Address]) {
        self.icon = icon
        self.title = title
        self.coordinates = coordinates
        self.contacts = contacts
        self.addresses = addresses
    }
   
}
