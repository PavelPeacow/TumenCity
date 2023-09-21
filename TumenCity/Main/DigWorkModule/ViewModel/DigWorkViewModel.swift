//
//  DigWorkViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import MapKit
import RxSwift
import RxRelay
import Alamofire

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
    
    var onError: ((AFError) -> ())?
    
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
        let result = await APIManager().fetchDataWithParameters(type: DigWork.self,
                                                                endpoint: .digWork(filter: filter))
        switch result {
        case .success(let success):
            digWorkElements = success.features
            addDigWorkAnnotations()
        case .failure(let failure):
            print(failure)
            onError?(failure)
        }
        isLoading.accept(false)
    }
    
    func addDigWorkAnnotations() {
        let annotations = digWorkElements.compactMap { element in
            if let lat = element.geometry.coordinates?.first, let long = element.geometry.coordinates?.last {
                return MKDigWorkAnnotation(
                    title: element.info.balloonContentHeader,
                    address: element.options.address ?? "",
                    contentDescription: element.info.balloonContentBody,
                    icon: UIImage(named: "digWorkPin") ?? .add,
                    coordinates: CLLocationCoordinate2D(latitude: lat, longitude: long)
                )
            }
            return nil
        }
        
        digWorkAnnotations
            .onNext(annotations)
    }
    
}
