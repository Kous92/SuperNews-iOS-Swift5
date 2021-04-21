//
//  Country.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 20/04/2021.
//

import Foundation

// MARK: - Welcome
struct Countries: Codable {
    let countries: [Country]
}

// MARK: - Country
struct Country: Codable {
    let countryCode, countryName, capital: String
    let lat, lon: Double
}
