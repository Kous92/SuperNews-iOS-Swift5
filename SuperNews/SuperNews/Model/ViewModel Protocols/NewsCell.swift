//
//  NewsCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 11/01/2022.
//

import Foundation

protocol NewsCell {
    var article: Article { get }
    var articleTitle: String { get }
    var articleImage: String { get }
    var articleSource: String { get }
}
