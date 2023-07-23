//
//  DigWorkViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import MapKit
import RxSwift
import RxRelay

@MainActor
final class DigWorkViewModel {
    
    private var digWorkElements = [DigWorkElement]()
    private var digWorkAnnotations = BehaviorSubject<[MKDigWorkAnnotation]>(value: [])
    var searchQuery = PublishSubject<String>()
    private var isLoading = BehaviorRelay(value: false)
    
    var digWorkAnnotationsObservable: Observable<[MKDigWorkAnnotation]> {
        digWorkAnnotations.asObservable()
    }
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            await getDigWorkElements()
        }
    }
    
    func findAnnotationByAddressName(_ address: String) -> Observable<MKDigWorkAnnotation?> {
        digWorkAnnotations
            .map { annotations in
                annotations.first(where: { $0.address.lowercased().contains(address.lowercased()) } )
            }
    }
    
    func isClusterWithTheSameCoordinates(annotations: [MKDigWorkAnnotation]) -> Bool {
        guard let firstAnnotation = annotations.first else {
            return false
        }
        
        let remainingAnnotations = annotations.dropFirst()
        
        let hasSameTitles = remainingAnnotations.allSatisfy { $0.title == firstAnnotation.title }
        let hasSameLatitude = remainingAnnotations.allSatisfy {
            abs($0.coordinates.latitude - firstAnnotation.coordinates.latitude) < 0.0001
        }
        
        return hasSameTitles || hasSameLatitude
    }
    
    func getDigWorkElements(filter: DigWorkFilter? = nil) async {
        isLoading.accept(true)
        do {
            let result = try await APIManager().getAPIContent(type: DigWork.self, endpoint: .digWork(filter: filter))
            digWorkElements = result.features
            addDigWorkAnnotations()
        } catch {
            print(error)
        }
        isLoading.accept(false)
    }
    
    func addDigWorkAnnotations() {
        let annotations = digWorkElements.map { element in
            let lat = element.geometry.coordinates.first ?? 0
            let long = element.geometry.coordinates.last ?? 0
            
            return MKDigWorkAnnotation(title: element.info.balloonContentHeader, address: element.options.address ?? "",
                                       contentDescription: element.info.balloonContentBody,
                                       icon: UIImage(named: "digWorkPin") ?? .add,
                                       coordinates: CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
        
        digWorkAnnotations
            .onNext(annotations)
    }
    
}
