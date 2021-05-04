//
//  SettingsSection.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import Foundation

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case NewsLanguage
    case NewsCountry
    
    var description: String {
        switch self {
        case .NewsLanguage:
            return "language"
        case .NewsCountry:
            return "country"
        }
    }
}
