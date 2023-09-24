//
//  isClusterWithTheSameCooridnates.swift
//  TumenCity
//
//  Created by Павел Кай on 24.09.2023.
//

import Foundation

func isClusterWithTheSameCoordinates<T: YMKAnnotation>(annotations: [T]) -> Bool {
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
