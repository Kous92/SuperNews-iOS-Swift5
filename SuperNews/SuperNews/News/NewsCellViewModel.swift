//
//  NewsCellViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/12/2021.
//

import Foundation

final class NewsCellViewModel: NewsCell {
    let article: Article
    let articleTitle: String
    let articleImage: String
    let articleSource: String
    
    // Injection de dépendance
    init(article: Article) {
        self.article = article
        self.articleTitle = article.title ?? "Titre indisponible"
        self.articleImage = article.urlToImage ?? ""
        self.articleSource = article.source?.name ?? "Source inconnue"
    }
}
