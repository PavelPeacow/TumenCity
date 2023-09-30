//
//  MainMapViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit
import YandexMapsMobile
import RxSwift
import RxRelay
import Combine
import Alamofire

@MainActor
final class CommunalServicesViewModel {
    
    //MARK: - Properties
    private let communalAnnotations = BehaviorSubject<[MKItemAnnotation]>(value: [])
    private let filteredAnnotations = BehaviorSubject<([MKItemAnnotation], [CommunalServicesFormatted])>(value: ([], []))
    
    var communalAnnotationsObservable: Observable<[MKItemAnnotation]> {
        communalAnnotations.asObservable()
    }
    var filteredAnnotationsObservable: Observable<([MKItemAnnotation], [CommunalServicesFormatted])> {
        filteredAnnotations.asObservable()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isLoading = BehaviorRelay<Bool>(value: true)
    var searchQuery = PublishSubject<String>()
    
    var isLoadingObservable: Observable<Bool> {
        isLoading.asObservable()
    }
    
    var communalServices: CommunalServices?
    var communalServicesFormatted = [CommunalServicesFormatted]()
    
    var onError: ((AFError) -> ())?
    
    init() {
        Task {
            await getCommunalServices()
        }
    }
    
    func filterCommunalServices(with filterID: Int) {
        if let communalValue = try? communalAnnotations.value() {
            let filtered = communalValue.filter { $0.markDescription.accidentID.rawValue == filterID }
            let communalServicesFiltered = communalServicesFormatted
                .filter { $0.mark.contains(where: { $0.accidentID.rawValue == filterID }) }
            filteredAnnotations
                .onNext((filtered, communalServicesFiltered))
        }
    }
    
    func resetFilterCommunalServices() {
        if let communalValue = try? communalAnnotations.value() {
            let communalServicesFiltered = communalServicesFormatted
            filteredAnnotations
                .onNext((communalValue, communalServicesFiltered))
        }
    }
    
    func findAnnotationByAddressName(_ address: String) -> MKItemAnnotation? {
        return try? filteredAnnotations
            .value() // Get the current value from BehaviorSubject
            .0
            .first(where: { $0.markDescription.address.lowercased().contains(address.lowercased()) })
    }

    
    //MARK: - API Call
    
    func getCommunalServices() async {
        isLoading.accept(true)
        await APIManager().fetchDataWithParameters(type: CommunalServices.self,
                                                   endpoint: .communalServices)
        .publisher
        .sink { completion in
            self.isLoading.accept(false)
            if case let .failure(error) = completion {
                self.onError?(error)
            }
        } receiveValue: { success in
            self.communalServices = success
            
            self.formatData()
            self.addAnnotations()
        }
        .store(in: &cancellables)
    }
    
    
    //MARK: - Format Date
    
    private func formatDateString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.date(from: dateString)!
    }
    
    private func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let currentDay = calendar.component(.day, from: Date())
        return currentDay >= day
    }
    
    //MARK: - Format data
    
    private func formatData() {
        communalServices?.card.forEach { card in
#warning("Check for date, but it unnesessary")
            guard isDateToday(formatDateString(card.datStart)) else { print("future date"); print(card.datStart); return }
            let cardID = card.numCard
            let workType = card.vidWork
            let dateStart = card.datStart
            let dateFinish = card.datFinish
            let orgTitle = card.usOrg
            
            var form = CommunalServicesFormatted(cardID: cardID,
                                                 workType: workType, dateStart: dateStart,
                                                 dateFinish: dateFinish, orgTitle: orgTitle,
                                                 mark: [])
            
            communalServices?.mark.forEach { mark in
                if mark.properties.listCard == form.cardID {
                    
                    let coordinates = Coordinates(latitude: mark.geometry.coordinates.first ?? 0, lontitude: mark.geometry.coordinates.last ?? 0)
                    var mapMark = MarkDescription(accident: "", accidentID: MarkType(rawValue: mark.properties.accident.id) ?? .none, address: mark.properties.address, coordinates: coordinates)
                    
                    communalServices?.info.forEach { info in
                        if info.id == mark.properties.accident.id {
                            mapMark.accident = info.title
                        }
                    }
                    
                    form.mark.append(mapMark)
                }
            }
            
            communalServicesFormatted.append(form)
        }
        
    }
    
    private func getCommunalImageAndColor(by intEnum: MarkType) -> (UIImage?, UIColor) {
        switch intEnum {
            
        case .cold:
            return (UIImage(named: "filter-1"), .blue)
        case .hot:
            return (UIImage(named: "filter-2"), .red)
        case .otop:
            return (UIImage(named: "filter-4"), .green)
        case .electro:
            return (UIImage(named: "filter-5"), .orange)
        case .gaz:
            return (UIImage(named: "filter-6"), .cyan)
        case .none:
            return (UIImage(systemName: "circle.fill"), .white)
        }
    }
    
    //MARK: - Add annotations
    
    private func addAnnotations() {
        var createdAnnotations = [MKItemAnnotation]()
        
        communalServicesFormatted.forEach { card in
            card.mark.forEach { mark in
                let annotationIconAndColor = getCommunalImageAndColor(by: mark.accidentID)
                
                let coordinate = CLLocationCoordinate2D(latitude: mark.coordinates.latitude, longitude: mark.coordinates.lontitude)
                let annotation = MKItemAnnotation(coordinates: coordinate, workType: card.workType,
                                                  dateStart: card.dateStart, dateFinish: card.dateFinish,
                                                  orgTitle: card.orgTitle, markDescription: mark, markIcon: annotationIconAndColor.0 ?? .actions, markColor: annotationIconAndColor.1, index: mark.accidentID.rawValue)
                createdAnnotations.append(annotation)
            }
        }
        
        communalAnnotations
            .onNext(createdAnnotations)
        communalAnnotations
            .onCompleted()
        filteredAnnotations
            .onNext((createdAnnotations, communalServicesFormatted))
    }
    
}
