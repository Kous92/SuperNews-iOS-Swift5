//
//  NewsArticle.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 11/01/2022.
//

import Foundation

protocol NewsArticle: NewsCell {
    var publishDate: String { get }
    var author: String { get }
    var content: String { get }
    var sourceURL: String { get }
}
