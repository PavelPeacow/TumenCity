//
//  SportViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import MapKit

protocol SportViewModelDelegate: AnyObject {
    func didFinishAddingAnnotations(_ annotations: [MKSportAnnotation])
}

@MainActor
class SportViewModel {
    
    var sportElements = [SportElement]()
    var sportAnnotations = [MKSportAnnotation]()
    
    weak var delegate: SportViewModelDelegate?
    
    init() {
        Task {
            await getSportElements()
            addSportAnnotations()
            
            delegate?.didFinishAddingAnnotations(sportAnnotations)
        }
    }
    
    func getSportElements() async {
        do {
            let result = try await APIManager().getAPIContent(type: [SportElement].self, endpoint: .sport)
            sportElements = result
        } catch {
            print(error)
        }
    }
    
    func addSportAnnotations() {
        print("che")
        sportElements.forEach { element in
            
            let title = element.title
            let contacts = element.contacts
            let addresses = element.addresses
            
            element.addresses.forEach { address in
                
                let long = address.longitude
                let lat = address.latitude
                
                let longFormatted: Any?
                let latFormatted: Any?
                
                switch long {
                    
                case .double(let double):
                    longFormatted = double
                case .string(let string):
                    longFormatted = string
                }
                
                switch lat {
                    
                case .double(let double):
                    latFormatted = double
                case .string(let string):
                    latFormatted = string
                }
                
                if let longStr = longFormatted as? String, let latStr = latFormatted as? String {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: Double(latStr) ?? 0, longitude: Double(longStr) ?? 0), contacts: contacts, addresses: addresses)
                    sportAnnotations.append(annotation)
                }
                
                if let longDouble = longFormatted as? Double, let latDouble = latFormatted as? Double {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble), contacts: contacts, addresses: addresses)
                    sportAnnotations.append(annotation)
                }
                
                
            }

            
        }
    }
    
}
