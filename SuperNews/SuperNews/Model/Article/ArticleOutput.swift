//
//  ArticleOutput.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 11/01/2022.
//

import Foundation

// MARK: - Response
struct ArticleOutput: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}
