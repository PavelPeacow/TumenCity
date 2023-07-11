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
    private var digWorkAnnotations = PublishSubject<[MKDigWorkAnnotation]>()
    private var isLoading = BehaviorRelay(value: false)
    
    var digWorkAnnotationsObservable: Observable<[MKDigWorkAnnotation]> {
        digWorkAnnotations.asObservable()
    }
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    init() {
        Task {
            isLoading.accept(true)
            await getDigWorkElements()
            isLoading.accept(false)
            addDigWorkAnnotations()
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
    
    private func getDigWorkElements() async {
        do {
            let result = try await APIManager().decodeMock(type: DigWork.self, forResourse: "digWorkMock")
            digWorkElements = result.features
        } catch {
            print(error)
        }
    }
    
    func addDigWorkAnnotations() {
        let annotations = digWorkElements.map { element in
            let lat = element.geometry.coordinates.first ?? 0
            let long = element.geometry.coordinates.last ?? 0
            
            return MKDigWorkAnnotation(title: element.info.balloonContentHeader,
                                       contentDescription: element.info.balloonContentBody,
                                       icon: UIImage(named: "digWorkPin") ?? .add,
                                       coordinates: CLLocationCoordinate2D(latitude: lat, longitude: long))
        }
        digWorkAnnotations
            .onNext(annotations)
        digWorkAnnotations
            .onCompleted()
    }
    
}
