//
//  NewsViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 26/11/2021.
//

import Foundation
import Combine

final class NewsViewModel: MainNews {
    // Les sujets, ceux qui émettent et reçoivent des événements
    var updateResult = PassthroughSubject<Bool, NewsAPIError>()
    var languageUpdated = PassthroughSubject<String, Never>()
    var isLoading = PassthroughSubject<Bool, Never>()
    @Published var searchQuery = ""
    @Published var countryCode = "fr"
    public private(set) var countryName = ""
    public private(set) var languageCode = "fr"
    public private(set) var languageName = "Français"
    
    private var newsData: ArticleOutput?
    var newsViewModels = [NewsCellViewModel]()
    private let apiService: APIService
    
    // Pour la gestion mémoire et l'annulation des abonnements
    private var subscriptions = Set<AnyCancellable>()
    
    // Injection de dépendance
    init(apiService: APIService = NewsAPIService()) {
        self.apiService = apiService
        setBindings()
    }
    
    private func setBindings() {
        $searchQuery
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .sink { [weak self] value in
                self?.searchNews()
            }.store(in: &subscriptions)
        
        $countryCode
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.initNews()
            }.store(in: &subscriptions)
    }
    
    func initNews() {
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
    
}

extension NewsViewModel {
    private func searchNews() {
        isLoading.send(true)
        
        guard !searchQuery.isEmpty else {
            initNews()
            return
        }
        
        apiService.searchNews(language: languageCode, query: searchQuery) { [weak self] result in
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
    
    func loadCountryAndLanguage() {
        countryCode = UserDefaults.standard.string(forKey: "countryCode") ?? "fr"
        languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "fr"
        languageName = UserDefaults.standard.string(forKey: "languageName") ?? "Français"
        
        languageUpdated.send(languageName)
    }
    
    // L'utilisateur a choisi un pays différent dans les paramètres.
    func checkCountry() {
        // L'utilisateur a choisi un pays différent dans les paramètres.
        if let code = UserDefaults.standard.string(forKey: "countryCode"), code != countryCode {
            countryCode = code
            print("\(code) != \(countryCode)")
            
            // L'actualisation ne se fait que s'il y a eu un changement de pays
            initNews()
        }
    }
    
    // L'utilisateur a choisi une langue différente dans les paramètres.
    func checkLanguage() {
        if let language = UserDefaults.standard.string(forKey: "languageCode"), let name = UserDefaults.standard.string(forKey: "languageName"), name != languageName && language != languageCode {
            languageCode = language
            languageName = name
            
            languageUpdated.send(languageName)
        }
    }
}
