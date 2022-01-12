//
//  Country.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 20/04/2021.
//

import Foundation

// MARK: - Country
struct Country: Decodable {
    let countryCode, countryName, capital: String
    let lat, lon: Double
}
