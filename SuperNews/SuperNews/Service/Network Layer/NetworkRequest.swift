//
//  NetworkRequest.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 26/11/2021.
//

import Foundation
import Alamofire

// MARK: - Appel réseau générique en GET pour chaque endpoint de l'API
class NetworkRequest {
    func getRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, NewsAPIError>) -> ()) {
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
