//
//  LocalServiceError.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 14/12/2021.
//

import Foundation

enum LocalServiceError: String, Error {
    case noCountries = "Aucun pays disponible"
    case noLanguage = "Aucune langue disponible"
}
