//
//  ArticleViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/12/2021.
//

import Foundation
import Combine

final class ArticleViewModel: NewsArticle {
    let article: Article
    
    @Published private(set) var articleTitle: String
    @Published private(set) var articleImage: String
    @Published private(set) var articleSource: String
    @Published private(set) var publishDate: String
    @Published private(set) var author: String
    @Published private(set) var content: String
    @Published private(set) var sourceURL: String
    
    // Injection de dépendance
    init(article: Article) {
        self.article = article
        self.articleTitle = article.title ?? "Titre indisponible"
        self.articleImage = article.urlToImage ?? ""
        self.articleSource = article.source?.name ?? "Source indisponible"
        self.publishDate = stringToDateFormat(date: article.publishedAt) ?? "Date de publication indisponible"
        self.author = article.author ?? "Auteur indisponible"
        self.content = article.content ?? "Contenu de l'article indisponible"
        self.sourceURL = article.url ?? ""
    }
    
    func getURL() -> URL? {
        // On ouvre le navigateur
        guard !sourceURL.isEmpty, let url = URL(string: sourceURL) else {
            print("-> ERREUR: URL de la source indisponible.")
            return nil
        }
        
        return url
    }
}
