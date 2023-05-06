//
//  MainMapViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit
import YandexMapsMobile

protocol CommunalServicesViewModelDelegate: AnyObject {
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation])
    func didUpdateAnnotations(_ annotations: [MKItemAnnotation])
}

final class CommunalServicesViewModel {
    
    //MARK: - Properties
    
    var annotations = [MKItemAnnotation]()
    var filteredAnnotations = [MKItemAnnotation]()
    
    var communalServices: CommunalServices?
    var communalServicesFormatted = [CommunalServicesFormatted]()
    
    weak var delegate: CommunalServicesViewModelDelegate?
    
    init() {
        Task {
            await getCommunalServices()
            formatData()
            addAnnotations()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didFinishAddingAnnotations(self.annotations)
            }
            
        }
    }
    
    func filterCommunalServices(with filterID: Int) {
        filteredAnnotations = annotations.filter { $0.markDescription.accidentID == filterID }
        delegate?.didUpdateAnnotations(filteredAnnotations)
    }
    
    func resetFilterCommunalServices() {
        filteredAnnotations = annotations
        delegate?.didUpdateAnnotations(annotations)
    }
    
    func findAnnotationByAddressName(_ address: String) -> MKItemAnnotation? {
        return filteredAnnotations.first(where: { $0.markDescription.address.lowercased().contains(address.lowercased()) } )
    }
    
    func isClusterWithTheSameCoordinates(annotations: [MKItemAnnotation]) -> Bool {
        return annotations.dropFirst().allSatisfy( { $0.coordinate.latitude == annotations.first?.coordinate.latitude } )
    }
    
    //MARK: - API Call
    
    func getCommunalServices() async {
        do {
            let result = try await APIManager().getAPIContent(type: CommunalServices.self, endpoint: .communalServices)
            communalServices = result
        } catch {
            print(error)
        }
    }
    
    //MARK: - Format Date
    
    private func formatDateString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter.date(from: dateString)!
    }
    
    private func isDateToday(_ date: Date) -> Bool {
        return Date() >= date
    }
    
    //MARK: - Format data
    
    private func formatData() {
        communalServices?.card.forEach { card in
            #warning("Check for date, but it unnesessary")
//            guard isDateToday(formatDateString(card.datStart)) else { print("future date"); print(card.datStart); return }
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
                    var mapMark = MarkDescription(accident: "", accidentID: mark.properties.accident.id, address: mark.properties.address, coordinates: coordinates)
                    
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
    
    //MARK: - Add annotations
    
    private func addAnnotations() {
        communalServicesFormatted.forEach { card in
            
            card.mark.forEach { mark in
                let coordinate = CLLocationCoordinate2D(latitude: mark.coordinates.latitude, longitude: mark.coordinates.lontitude)
                let annotation = MKItemAnnotation(coordinate: coordinate, workType: card.workType,
                                                  dateStart: card.dateStart, dateFinish: card.dateFinish,
                                                  orgTitle: card.orgTitle, markDescription: mark, markType: mark.accidentID)
                annotations.append(annotation)
            }
            
        }
        
        filteredAnnotations = annotations
        
    }
    
}
