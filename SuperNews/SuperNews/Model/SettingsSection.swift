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
    case NewsReset
    
    var description: String {
        switch self {
        case .NewsLanguage:
            return "language"
        case .NewsCountry:
            return "country"
        case .NewsReset:
            return "reset"
        }
    }
    
    var detail: String {
        switch self {
        case .NewsLanguage:
            return "Langue des news"
        case .NewsCountry:
            return "Pays des news"
        case .NewsReset:
            return "Réinitialiser les paramètres"
        }
    }
}
