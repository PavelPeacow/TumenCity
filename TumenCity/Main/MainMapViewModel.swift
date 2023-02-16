//
//  MainMapViewModel.swift
//  TumenCity
//
//  Created by Павел Кай on 16.02.2023.
//

import MapKit

protocol MainMapViewModelDelegate {
    func didFinishAddingAnnotations(_ annotations: [MKItemAnnotation])
}

final class MainMapViewModel {
    
    private var communalServices: CommunalServices?
    var communalServicesFormatted = [CommunalServicesFormatted]()
    
    var delegate: MainMapViewModelDelegate?
    
    init() {
        Task {
            await getCommunalServices()
            formatData()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didFinishAddingAnnotations(self.addAnnotations())
            }
            
        }
    }
    
    func setRegion() -> MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
    
    func getCommunalServices() async {
        do {
            let result = try await APIManager().getAPIContent(type: CommunalServices.self, endpoint: .communalServices)
            communalServices = result
        } catch {
            print(error)
        }
    }
    
    private func formatData() {
        communalServices!.card.forEach { card in
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
    
    private func addAnnotations() -> [MKItemAnnotation] {
        var annotations = [MKItemAnnotation]()
        
        communalServicesFormatted.forEach { card in
            
            card.mark.forEach { mark in
                let coordinate = CLLocationCoordinate2D(latitude: mark.coordinates.latitude, longitude: mark.coordinates.lontitude)
                let annotation = MKItemAnnotation(coordinate: coordinate, workType: card.workType,
                                                  dateStart: card.dateStart, dateFinish: card.dateFinish,
                                                  orgTitle: card.orgTitle, markDescription: mark, markType: mark.accidentID)
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    
}
