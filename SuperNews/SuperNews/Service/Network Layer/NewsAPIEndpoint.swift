//
//  NewsAPIEndpoint.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 26/11/2021.
//

import Foundation

enum NewsAPIEndpoint {
    case initNews(country: String)
    case searchNews(language: String, query: String)
    
    var baseURL: String {
        return "https://newsapi.org/v2/"
    }
    
    var path: String {
        switch self {
        case .initNews(let country):
            return "top-headlines?country=\(country)"
        case .searchNews(let language, let query):
            return "everything?language=\(language)&q=\(query)&sortBy=publishedAt"
        }
    }
}
