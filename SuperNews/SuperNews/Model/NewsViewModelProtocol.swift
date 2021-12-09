//
//  NewsViewModelProtocol.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/12/2021.
//

import Foundation

protocol NewsCell {
    var article: Article { get }
    var articleTitle: String { get }
    var articleImage: String { get }
    var articleSource: String { get }
}

protocol NewsArticle {
    var publishDate: String { get }
    var author: String { get }
    var content: String { get }
    var sourceURL: String { get }
}
