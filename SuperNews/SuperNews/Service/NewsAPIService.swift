//
//  NewsAPIService.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 14/04/2021.
//

import Foundation
import Alamofire

final class NewsAPIService: APIService {
    private var apiKey: String = ""
    var keyUnitTestMode: Bool
    
    private func getApiKey() -> String? {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist") else {
            print("ERREUR: Fichier ApiKey.plist inexistant")
            return nil
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) else {
            print("ERREUR: Données indisponibles")
            return nil
        }
        
        return dictionary.object(forKey: "NewsApiKey") as? String
    }
    
    init() {
        self.keyUnitTestMode = false
        self.apiKey = getApiKey() ?? ""
    }
    
    
    func searchNews(language: String = "fr", query: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        // Cela sera surtout utile dans le cadre des tests unitaires.
        if apiKey.isEmpty && keyUnitTestMode == false {
            apiKey = getApiKey() ?? ""
        }
        
        getRequest(endpoint: .searchNews(language: language, query: query.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? ""), completion: completion)
    }
    
    func initializeLocalNews(country: String, completion: @escaping (Result<ArticleOutput, NewsAPIError>) -> ()) {
        // Cela sera surtout utile dans le cadre des tests unitaires.
        if apiKey.isEmpty && keyUnitTestMode == false {
            apiKey = getApiKey() ?? ""
        }
        
        getRequest(endpoint: .initNews(country: country), completion: completion)
        
    }
    
    private func getRequest<T: Decodable>(endpoint: NewsAPIEndpoint, completion: @escaping (Result<T, NewsAPIError>) -> ()) {
        guard let url = URL(string: endpoint.baseURL + endpoint.path + "&apiKey=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("URL appelée: \(url.absoluteString)")
        
        AF.request(url).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success:
                guard let data = response.value else {
                    completion(.failure(.downloadError))
                    return
                }
                
                completion(.success(data))
            case let .failure(error):
                guard let httpResponse = response.response else {
                    print("ERREUR: \(error)")
                    completion(.failure(.networkError))
                    return
                }
                
                switch httpResponse.statusCode {
                case 400:
                    completion(.failure(.parametersMissing))
                case 401:
                    completion(.failure(.invalidApiKey))
                case 404:
                    completion(.failure(.notFound))
                case 429:
                    completion(.failure(.tooManyRequests))
                case 500:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
