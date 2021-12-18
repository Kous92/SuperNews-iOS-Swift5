//
//  NewsMockService.swift
//  SuperNewsTests
//
//  Created by Koussaïla Ben Mamar on 08/12/2021.
//

import Foundation
@testable import SuperNews

final class NewsMockService: APIService {
    func initializeLocalNews(country: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        guard let data = loadLocalData(with: "localDataTest") else {
            completion(.failure(.decodeError))
            
            return
        }
        
        completion(.success(data))
    }
    
    func searchNews(language: String, query: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        guard query != "Crise" else {
            completion(.failure(.invalidURL))
            
            return
        }
        
        guard let data = loadLocalData(with: "queryDataTest") else {
            completion(.failure(.decodeError))
            
            return
        }
        
        completion(.success(data))
    }
    
    func mockTooManyRequests(completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        completion(.failure(.tooManyRequests))
    }
    
    func mockNotFound(completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        completion(.failure(.notFound))
    }
    
    func mockDownloadError(completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        completion(.failure(.downloadError))
    }
    
    func mockNoArticles(completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        completion(.failure(.noArticles))
    }
    
    func mockServerError(completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        completion(.failure(.serverError))
    }
    
    private func loadLocalData(with source: String) -> ArticleOutput? {
        // Vérification de l'existence du fichier local countries.json
        guard let path = Bundle.main.path(forResource: source, ofType: "json") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        var output: ArticleOutput
        
        do {
            // Récupération des données JSON en type Data
            let data = try Data(contentsOf: url)
            
            // Décodage des données JSON en objets exploitables
            output = try JSONDecoder().decode(ArticleOutput.self, from: data)
            
            return output
        } catch {
            print("ERREUR: \(error)")
        }
        
        return nil
    }
}


