//
//  Language.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import Foundation

// MARK: - Language
struct Language: Decodable {
    let languageCode, languageName, languageDefaultFlag: String
    let defaultLanguage: Bool
}
