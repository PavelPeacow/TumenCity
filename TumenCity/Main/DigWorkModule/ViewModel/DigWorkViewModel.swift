//
//  DigWorkViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 09.05.2023.
//

import MapKit
import Combine
import Alamofire

@MainActor
final class DigWorkViewModel {
    
    private var digWorkElements = [DigWorkElement]()
    @Published private var digWorkAnnotations = [MKDigWorkAnnotation]()
    @Published var searchQuery = ""
    @Published private var isLoading = true
    var cancellables = Set<AnyCancellable>()
    
    var digWorkAnnotationsObservable: AnyPublisher<[MKDigWorkAnnotation], Never> {
        $digWorkAnnotations.eraseToAnyPublisher()
    }
    var searchQueryObservable: AnyPublisher<String, Never> {
        $searchQuery.eraseToAnyPublisher()
    }
    var isLoadingObservable: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var onError: ((AFError) -> ())?
    var onEmptyResult: (() -> ())?
    
    init() {
        Task {
            await getDigWorkElements()
        }
    }
    
    func findAnnotationByAddressName(_ address: String) -> AnyPublisher<MKDigWorkAnnotation?, Never> {
        $digWorkAnnotations
            .map { annotations in
                annotations.first(where: { $0.address.lowercased().contains(address.lowercased()) } )
            }
            .eraseToAnyPublisher()
    }
    
    func getDigWorkElements(filter: DigWorkFilter? = nil) async {
        isLoading = true
        await APIManager().fetchDataWithParameters(type: DigWork.self,
                                                   endpoint: .digWork(filter: filter))
        .publisher
        .sink { completion in
            self.isLoading = false
            if case let .failure(error) = completion {
                self.onError?(error)
            }
        } receiveValue: { digWork in
            if digWork.features.isEmpty {
                self.onEmptyResult?()
                return
            }
            self.digWorkElements = digWork.features
            self.addDigWorkAnnotations()
        }
        .store(in: &cancellables)
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
        
        digWorkAnnotations = annotations
    }
    
}
