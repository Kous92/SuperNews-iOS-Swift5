//
//  CountryCellViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 13/12/2021.
//

import Foundation
import CoreLocation

final class CountryCellViewModel {
    let countryCode: String
    let countryName: String
    let coordinates: CLLocation
    
    // Injection de dépendance
    init(with country: Country) {
        self.countryCode = country.countryCode
        self.countryName = country.countryName
        self.coordinates = CLLocation(latitude: country.lat, longitude: country.lon)
    }
}
