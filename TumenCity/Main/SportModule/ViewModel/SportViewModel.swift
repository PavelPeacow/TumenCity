//
//  SportViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 06.05.2023.
//

import UIKit
import MapKit
import RxSwift
import RxRelay

@MainActor
final class SportViewModel {
    
    private var sportElements = PublishSubject<[SportElement]>()
    private var sportAnnotations = BehaviorSubject<[MKSportAnnotation]>(value: [])
    private var isLoading = BehaviorRelay<Bool>(value: false)
    var searchQuery = PublishSubject<String>()
    
    var sportElementsObservable: Observable<[SportElement]> {
        sportElements.asObservable()
    }
    var sportAnnotationsObservable: Observable<[MKSportAnnotation]> {
        sportAnnotations.asObservable()
    }
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            isLoading.accept(true)
            await getSportElements()
            isLoading.accept(false)
        }
    }
    
    func searchAnnotationByName(_ name: String) -> Observable<MKSportAnnotation?> {
        sportAnnotations
            .map { annotations in
                let filteredAnnotations = annotations.filter { annotation in
                    let annotationTitle = annotation.title.lowercased()
                    let searchKeyword = name.lowercased()
                    return annotationTitle.contains(searchKeyword)
                }
                return filteredAnnotations.first
            }
    }
    
    func getSportElements() async {
        do {
            let result = try await APIManager().getAPIContent(type: [SportElement].self, endpoint: .sport)
            sportElements
                .onNext(result)
            sportElements
                .onCompleted()
        } catch {
            print(error)
        }
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
                
                if let longStr = longFormatted as? String, let latStr = latFormatted as? String {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: Double(latStr) ?? 0, longitude: Double(longStr) ?? 0), contacts: contacts, addresses: addresses)
                    annotations.append(annotation)
                }
                
                if let longDouble = longFormatted as? Double, let latDouble = latFormatted as? Double {
                    let annotation = MKSportAnnotation(icon: UIImage(named: "sportPin") ?? .add, title: title, coordinates: CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble), contacts: contacts, addresses: addresses)
                    annotations.append(annotation)
                }
                
                
            }
        }
        
        sportAnnotations
            .onNext(annotations)
    }
    
}
