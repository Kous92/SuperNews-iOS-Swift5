//
//  SuperNewsTests.swift
//  SuperNewsTests
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import XCTest
import Combine
@testable import SuperNews

class SuperNewsTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    @Published var searchQuery = ""
    let newsViewModel = NewsViewModel(apiService: NewsMockService())
    let countryNewsViewModel = CountryNewsViewModel(apiService: NewsMockService())
    let apiService = NewsMockService()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchLocalCountriesJSON() {
        let data = getLocalCountryData()
        
        XCTAssertNotNil(data, "Données non disponibles")
    }
    
    func testFetchLocalLanguagesJSON() {
        let data = getLocalLanguageData()
        
        XCTAssertNotNil(data, "Données non disponibles")
    }
    
    func testDateFormatter() {
        let ISODate = "2021-12-15T20:35:58Z"
        let formatted = stringToDateFormat(date: ISODate)
        XCTAssertNotNil(formatted)
    }
    
    func testTodayDate() {
        let date = getTodayDate()
        print(date)
        XCTAssert(true)
    }
    
    func testTodayTime() {
        let time = getTodayTime()
        print(time)
        XCTAssert(true)
    }
    
    func testLocalCountry() {
        let data = getLocalCountryData() ?? []
        let country1 = data.filter { $0.countryCode == "fr"}[0]
        let country2 = data.filter { $0.countryCode == "us"}[0]
        
        XCTAssertEqual(country1.countryCode, "fr", "Erreur: le code du pays n'est pas fr, retourné: \(country1.countryCode)")
        XCTAssertEqual(country2.countryCode, "us", "Erreur: le code du pays n'est pas us, retourné: \(country2.countryCode)")
        XCTAssertEqual(country1.countryName, "France", "Erreur: le nom du pays n'est pas France, retourné: \(country1.countryName)")
        XCTAssertEqual(country2.countryName, "États-Unis", "Erreur: le nom du pays n'est pas États-Unis, retourné: \(country2.countryName)")
    }
    
    func testLocalLanguages() {
        let data = getLocalLanguageData() ?? []
        let language1 = data.filter { $0.languageCode == "fr"}[0]
        let language2 = data.filter { $0.languageCode == "en"}[0]
        
        XCTAssertEqual(language1.languageCode, "fr", "Erreur: le code de la langue n'est pas fr, retourné: \(language1.languageCode)")
        XCTAssertEqual(language2.languageCode, "en", "Erreur: le code de la langue n'est pas en, retourné: \(language2.languageCode)")
        XCTAssertEqual(language1.languageName, "Français", "Erreur: le nom de la langue n'est pas Français, retourné: \(language1.languageName)")
        XCTAssertEqual(language2.languageName, "Anglais", "Erreur: le nom de la langue n'est pas Anglais, retourné: \(language2.languageName)")
    }
    
    func testNewsCellViewModel() {
        guard let data = loadLocalData(with: "localDataTest") else {
            XCTFail("Erreur: pas de données.")
            
            return
        }

        let viewModel = NewsCellViewModel(article: data)
        
        XCTAssertEqual(viewModel.articleTitle, "PSG : Wenger dément une rumeur - Barça")
        XCTAssertEqual(viewModel.article.url, "https://news.maxifoot.fr/psg/wenger-dement-une-rumeur-foot-359827.htm")
    }
    
    func testNewsViewModel() {
        let expectation = XCTestExpectation(description: "Récupérer le contenu d'un article local.")
        
        newsViewModel.initNews()
        newsViewModel.updateResult
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(let error):
                    print("Erreur reçue: \(error.rawValue)")
                }
            } receiveValue: { updated in
                expectation.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertGreaterThan(newsViewModel.newsViewModels.count, 0)
    }
    
    func testNewsViewModelError() {
        let expectation1 = XCTestExpectation(description: "Entrée reçue")
        let expectation2 = XCTestExpectation(description: "Une erreur est retournée")
        
        searchQuery = "Crise"
        $searchQuery
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                print(value)
                self?.newsViewModel.searchQuery = value
                expectation1.fulfill()
            }.store(in: &subscriptions)
        
        newsViewModel.updateResult
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(_):
                    expectation2.fulfill()
                }
            } receiveValue: { updated in
                XCTFail()
            }.store(in: &subscriptions)
        
        wait(for: [expectation1, expectation2], timeout: 15)
    }
    
    func testNewsViewModelLanguageUpdate() {
        // let expectation1 = XCTestExpectation(description: "Entrée reçue")
        let expectation01 = XCTestExpectation(description: "Mise à jour effectuéee")
        
        newsViewModel.initNews()
        newsViewModel.loadCountryAndLanguage()
        
        newsViewModel.updateResult
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(_):
                    print("Erreur")
                }
            } receiveValue: { updated in
                expectation01.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [expectation01], timeout: 10)
    }
    
    func testArticleViewModel() {
        guard let data = loadLocalData(with: "localDataTest") else {
            XCTFail("Erreur: pas de données.")
            
            return
        }
        
        let viewModel = ArticleViewModel(article: data)
        let url = viewModel.getURL()
        
        XCTAssertEqual(url, URL(string: "https://news.maxifoot.fr/psg/wenger-dement-une-rumeur-foot-359827.htm"))
        XCTAssertEqual(viewModel.articleTitle, "PSG : Wenger dément une rumeur - Barça")
        XCTAssertEqual(viewModel.articleSource, "Maxifoot.fr")
    }
    
    func testCountryNewsViewModel() {
        let expectation4 = XCTestExpectation(description: "Récupérer le contenu d'un article local.")
        
        countryNewsViewModel.updateResult
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(let error):
                    print("Erreur reçue: \(error.rawValue)")
                }
            } receiveValue: { updated in
                expectation4.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [expectation4], timeout: 10)
        
        XCTAssertGreaterThan(countryNewsViewModel.newsViewModels.count, 0)
    }
    
    func testAPIService() {
        apiService.initializeLocalNews(country: "fr") { result in
            switch result {
            case .success(let output):
                XCTAssertNotNil(output.articles)
            case .failure(_):
                XCTFail()
            }
        }
    }

    func testAPIErrorNotFound() {
        apiService.mockNotFound { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Erreur 404: Aucun contenu disponible.")
            }
        }
    }
    
    func testAPIErrorTooManyRequests() {
        apiService.mockTooManyRequests { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Erreur 429: Trop de requêtes ont été effectuées dans un laps de temps. Veuillez réessayer ultérieurement.")
            }
        }
    }
    
    func testAPIErrorDownload() {
        apiService.mockDownloadError { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Une erreur est survenue au téléchargement des données.")
            }
        }
    }
    
    func testAPIErrorNoArticles() {
        apiService.mockNoArticles { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Pas d'articles disponibles.")
            }
        }
    }
    
    func testAPIServerError() {
        apiService.mockServerError { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Erreur 500: Erreur serveur.")
            }
        }
    }
    
    
}
