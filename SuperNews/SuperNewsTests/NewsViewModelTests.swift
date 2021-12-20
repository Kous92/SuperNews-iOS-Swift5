//
//  NewsViewModelTests.swift
//  SuperNewsTests
//
//  Created by Koussaïla Ben Mamar on 19/12/2021.
//

import Foundation
import XCTest
import Combine
@testable import SuperNews

/*
- Ici, les tests unitaires de la classe NewsViewModel
-> L'instanciation du ViewModel sera fait à chaque test afin de s'assurer que les tests passent, tout en étant indépendants entre eux.
-> Le mocking réseau est utilisé par le biais de l'injection de dépendance
*/
class NewsViewModelTests: XCTestCase {
    @Published var searchQuery = ""
    var subscriptions: Set<AnyCancellable> = []
    let viewModel = NewsViewModel(apiService: NewsMockService())
    
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
        let expectation1 = XCTestExpectation(description: "Récupérer le contenu d'un article local.")
        let newsViewModel = NewsViewModel(apiService: NewsMockService())
        
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
                expectation1.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [expectation1], timeout: 10)
        
        XCTAssertGreaterThan(newsViewModel.newsViewModels.count, 0)
    }
    
    func testNewsViewModelError() {
        let expectation2 = XCTestExpectation(description: "Entrée reçue")
        let expectation3 = XCTestExpectation(description: "Une erreur est retournée")
        // newsViewModel.initNews()
        
        searchQuery = "Crise"
        $searchQuery
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                print(value)
                viewModel.searchQuery = value
                expectation2.fulfill()
            }.store(in: &subscriptions)
        
        viewModel.updateResult
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(_):
                    expectation3.fulfill()
                }
            } receiveValue: { updated in
                XCTFail()
            }.store(in: &subscriptions)
        
        wait(for: [expectation2, expectation3], timeout: 15)
    }
    
    func testNewsViewModelLanguageUpdate() {
        // let expectation1 = XCTestExpectation(description: "Entrée reçue")
        let expectation4 = XCTestExpectation(description: "Mise à jour effectuéee")
        let newsViewModel = NewsViewModel(apiService: NewsMockService())
        
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
                expectation4.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [expectation4], timeout: 10)
    }
}
