//
//  Article.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 14/04/2021.
//

import Foundation

// MARK: - Article
struct Article: Decodable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}
