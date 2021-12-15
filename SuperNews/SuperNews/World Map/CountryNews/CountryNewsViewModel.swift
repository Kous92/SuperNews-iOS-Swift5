//
//  CountryNewsViewMode.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 12/12/2021.
//
import Foundation
import Combine

final class CountryNewsViewModel: CountryLocalNews {
    // Les sujets, ceux qui émettent et reçoivent des événements
    var updateResult = PassthroughSubject<Bool, NewsAPIError>()
    var isLoading = PassthroughSubject<Bool, Never>()
    @Published var countryCode: String
    @Published var countryName: String
    
    private var newsData: ArticleOutput?
    var newsViewModels = [NewsCellViewModel]()
    private let apiService: APIService
    
    // Pour la gestion mémoire et l'annulation des abonnements
    private var subscriptions = Set<AnyCancellable>()
    
    // Injection de dépendance
    init(apiService: APIService = NewsAPIService(), countryCode: String = "fr", countryName: String = "France") {
        self.countryCode = countryCode
        self.countryName = countryName
        self.apiService = apiService
        setBindings()
    }
    
    private func setBindings() {
        $countryCode
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.initLocalNews()
            }.store(in: &subscriptions)
    }
}

extension CountryNewsViewModel {
    func initLocalNews() {
        isLoading.send(true)
        
        apiService.initializeLocalNews(country: countryCode) { [weak self] result in
            switch result {
            case .success(let response):
                self?.newsData = response
                self?.parseData()
            case .failure(let error):
                print(error.rawValue)
                self?.updateResult.send(completion: .failure(error))
            }
        }
    }
    
    private func parseData() {
        guard let data = newsData?.articles, data.count > 0 else {
            // Pas d'article disponible
            updateResult.send(false)
            
            return
        }
        
        newsViewModels.removeAll()
        data.forEach { newsViewModels.append(NewsCellViewModel(article: $0)) }
        updateResult.send(true)
    }
}
