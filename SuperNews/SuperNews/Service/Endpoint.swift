//
//  Endpoint.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 26/11/2021.
//

import Foundation

protocol Endpoint {
    // HTTP ou HTTPS
    var scheme: String { get }
    
    // Ici: "newsapi.org/v2/"
    var baseURL: String { get }
    
    // "/top_headlines", "everything"
    var path: String { get }
    
    // [URLQueryItem(name: "api_key", value: API_KEY)]
    var parameters: [URLQueryItem] { get }
    
    // "GET", "POST", "PUT", "DELETE"
    var method: String { get }
}
