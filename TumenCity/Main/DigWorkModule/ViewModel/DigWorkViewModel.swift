//
//  DigWorkViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import MapKit

protocol DigWorkViewModelDelegate: AnyObject {
    func didFinishAddingAnnotations(_ annotations: [MKDigWorkAnnotation])
}

@MainActor
class DigWorkViewModel {
    
    var digWorkElements = [DigWorkElement]()
    var digWorkAnnotations = [MKDigWorkAnnotation]()
    
    weak var delegate: DigWorkViewModelDelegate?
    
    init() {
        Task {
            await getDigWorkElements()
            addDigWorkAnnotations()
            
            delegate?.didFinishAddingAnnotations(digWorkAnnotations)
        }
    }
    
    func isClusterWithTheSameCoordinates(annotations: [MKDigWorkAnnotation]) -> Bool {
        annotations.dropFirst().allSatisfy( { $0.title == annotations.first?.title } ) ||
        annotations.dropFirst().allSatisfy( { String(format: "%.4f", $0.coordinates.latitude) == String(format: "%.4f", annotations.first!.coordinates.latitude) } )
    }
    
    func getDigWorkElements() async {
        let result = await APIManager().decodeMock(type: DigWork.self, forResourse: "digWorkMock")
        digWorkElements = result.features
    }
    
    func addDigWorkAnnotations() {
        digWorkElements.forEach { element in
            let lat = element.geometry.coordinates.first ?? 0
            let long = element.geometry.coordinates.last ?? 0
            
            let annotation = MKDigWorkAnnotation(title: element.info.balloonContentHeader, contentDescription: element.info.balloonContentBody, icon: UIImage(named: "digWorkPin") ?? .add, coordinates: CLLocationCoordinate2D(latitude: lat, longitude: long))
            digWorkAnnotations.append(annotation)
        }
    }
    
}
