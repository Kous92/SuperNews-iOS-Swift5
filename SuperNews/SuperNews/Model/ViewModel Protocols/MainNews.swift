//
//  MainNews.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 11/01/2022.
//

import Foundation
import Combine

protocol MainNews {
    var updateResultPublisher: AnyPublisher<Bool, NewsAPIError> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var countryCode: String { get set }
    var newsViewModels: [NewsCellViewModel] { get }
}
