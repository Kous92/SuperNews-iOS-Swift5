//
//  Language.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import Foundation

// MARK: - Languages
struct Languages: Codable {
    let language: [Language]
}

// MARK: - Language
struct Language: Codable {
    let languageCode, languageName, languageDefaultFlag: String
    let defaultLanguage: Bool
}
