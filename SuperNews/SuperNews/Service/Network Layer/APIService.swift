//
//  APIService.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 26/11/2021.
//

import Foundation

protocol APIService {
    func initializeLocalNews(country: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ())
    func searchNews(language: String, query: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ())
}
