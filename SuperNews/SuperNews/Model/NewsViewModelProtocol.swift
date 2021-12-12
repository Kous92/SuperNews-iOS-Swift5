//
//  NewsViewModelProtocol.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/12/2021.
//

import Foundation
import Combine

protocol NewsCell {
    var article: Article { get }
    var articleTitle: String { get }
    var articleImage: String { get }
    var articleSource: String { get }
}

protocol NewsArticle: NewsCell {
    var publishDate: String { get }
    var author: String { get }
    var content: String { get }
    var sourceURL: String { get }
}

protocol MainNews {
    var updateResult: PassthroughSubject<Bool, NewsAPIError> { get set }
    var isLoading: PassthroughSubject<Bool, Never> { get set }
    var countryCode: String { get set }
    var newsViewModels: [NewsCellViewModel] { get }
}

protocol CountryLocalNews: MainNews {
    var countryName: String { get }
}
