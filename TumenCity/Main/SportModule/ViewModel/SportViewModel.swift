//
//  SportViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import MapKit
import Alamofire
import Combine

@MainActor
final class SportViewModel {
    
    @Published private var sportElements = [SportElement]()
    @Published private var sportAnnotations = [MKSportAnnotation]()
    @Published private var isLoading = true
    @Published var searchQuery = ""
    
    var cancellables = Set<AnyCancellable>()
    
    var sportElementsObservable: AnyPublisher<[SportElement], Never> {
        $sportElements.eraseToAnyPublisher()
    }
    var sportAnnotationsObservable: AnyPublisher<[MKSportAnnotation], Never> {
        $sportAnnotations.eraseToAnyPublisher()
    }
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getSportElements()
        }
    }
    
    func searchAnnotationByName(_ name: String) -> MKSportAnnotation? {
        let filteredAnnotations = sportAnnotations.filter { annotation in
            let annotationTitle = annotation.title.lowercased()
            let searchKeyword = name.lowercased()
            return annotationTitle.contains(searchKeyword)
        }
        return filteredAnnotations.first
    }

    func getSportElements() async {
        isLoading = true
        await APIManager().fetchDataWithParameters(type: [SportElement].self,
                                                   endpoint: .sport)
        .publisher
        .sink { completion in
            self.isLoading = false
            if case let .failure(error) = completion {
                print(error)
                self.onError?(error)
            }
        } receiveValue: { sportElements in
            self.sportElements = sportElements
        }
        .store(in: &cancellables)
    }
    
    
    func addSportAnnotations(objects: [SportElement]) {
        var annotations = [MKSportAnnotation]()
        
        objects.forEach { element in
            
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
                
                if let longStr = Double(longFormatted as? String ?? ""), let latStr = Double(latFormatted as? String ?? "") {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: latStr, longitude: longStr), contacts: contacts, addresses: addresses)
                    annotations.append(annotation)
                }
                
                if let longDouble = longFormatted as? Double, let latDouble = latFormatted as? Double {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble), contacts: contacts, addresses: addresses)
                    annotations.append(annotation)
                }
                
                
            }
        }
        
        sportAnnotations = annotations
    }
}
