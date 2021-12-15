//
//  AnnotationViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 13/12/2021.
//

import Foundation
import CoreLocation

final class AnnotationViewModel {
    let countryCode: String
    let countryName: String
    let coordinates: CLLocationCoordinate2D
    
    init(countryCode: String, countryName: String, coordinates: CLLocationCoordinate2D) {
        self.countryCode = countryCode
        self.countryName = countryName
        self.coordinates = coordinates
    }
}
