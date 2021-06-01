//
//  SuperNewsTests.swift
//  SuperNewsTests
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import XCTest
@testable import SuperNews

class SuperNewsTests: XCTestCase {

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
    
    func testLocalCountry() {
        let data = getLocalCountryData()
        let country1 = data?.filter { $0.countryCode == "fr"}[0]
        let country2 = data?.filter { $0.countryCode == "us"}[0]
        
        XCTAssertEqual(country1!.countryCode, "fr", "Erreur: le code du pays n'est pas fr, retourné: \(country1!.countryCode)")
        XCTAssertEqual(country2!.countryCode, "us", "Erreur: le code du pays n'est pas us, retourné: \(country2!.countryCode)")
        XCTAssertEqual(country1!.countryName, "France", "Erreur: le nom du pays n'est pas France, retourné: \(country1!.countryName)")
        XCTAssertEqual(country2!.countryName, "États-Unis", "Erreur: le nom du pays n'est pas États-Unis, retourné: \(country2!.countryName)")
    }
    
    func testFetchLocalLanguagesJSON() {
        let data = getLocalLanguageData()
        
        XCTAssertNotNil(data, "Données non disponibles")
    }
    
    // Test réseau asynchrone
    func testFetchLocalNewsNetwork() {
        let expectation = expectation(description: "Récupérer les news locales par le réseau.")
        let newsAPI = NewsAPIService.shared
        newsAPI.keyUnitTestMode = false
        
        newsAPI.initializeLocalNews(country: "fr", completion: { result in
            expectation.fulfill()
            switch result {
            case .success(let newsData):
                print(newsData.count)
                XCTAssertGreaterThan(newsData.count, 0)
            case .failure(_):
                XCTFail()
                print("Pas de données")
            }
        })
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    // Test réseau asynchrone
    func testFetchQueryNewsNetwork() {
        let expectation = expectation(description: "Récupérer les news locales par le réseau avec une recherche.")
        let newsAPI = NewsAPIService.shared
        newsAPI.keyUnitTestMode = false
        
        newsAPI.searchNews(language: "fr", query: "Apple") { result in
            expectation.fulfill()
            switch result {
            case .success(let newsData):
                print(newsData.count)
                XCTAssertGreaterThan(newsData.count, 0)
            case .failure(_):
                XCTFail()
                print("Pas de données")
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testNoArticlesAvailableFetch() {
        let expectation = expectation(description: "Vérifier que sur une recherche farfelue que l'erreur est retournée.")
        let newsAPI = NewsAPIService.shared
        newsAPI.keyUnitTestMode = false
        
        newsAPI.searchNews(language: "fr", query: "rjbkbt21521") { result in
            expectation.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Pas d'articles disponibles.", "L'erreur attendue ne s'est pas déclenchée.")
                print(error.rawValue)
                print(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testNoAPIKeyFetch() {
        let expectation = expectation(description: "Récupérer les news locales par le réseau avec une recherche.")
        let newsAPI = NewsAPIService.shared
        newsAPI.keyUnitTestMode = true
        newsAPI.apiKey = ""
        
        newsAPI.searchNews(language: "fr", query: "Apple") { result in
            expectation.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.rawValue, "Erreur 401: La clé d'API fournie est invalide ou inexistante.", "L'erreur 401 n'est pas déclenchée.")
                print(error.rawValue)
                print(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
