//
//  NewsAPIService.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 14/04/2021.
//

import Foundation
import Alamofire

class NewsAPIService {
    // Ici une seule instance (singleton) suffit pour le monitoring du réseau
    static let shared = NewsAPIService()
    
    let url: String = "https://newsapi.org/v2/top-headlines?country="
    var initURL: URL
    let apiKey: String = "1e78ee975c234d6d917ddcfc008123fb"
    var country: String
    /*
    private var apiKey: String = {
        get {
            // 1
            guard let filePath = Bundle.main.path(forResource: "ApiKey", ofType: "plist") else {
                fatalError("Le fichier 'ApiKey.plist' n'existe pas.")
            }
            // 2
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "NewsApiKey") as? String else {
                fatalError("Impossible de trouver la clé 'NewsApiKey' dans 'ApiKey.plist'.")
            }
            // 3
            if (value.starts(with: "_")) {
            fatalError("Register for a TMDB developer account and get an API key at https://developers.themoviedb.org/3/getting-started/introduction.")
            }
            return value
        }
    }
     */
    // Le cache pour les images déjà téléchargées
    private var images = NSCache<NSString, NSData>()
    
    // Cette session va permettre de ne pas solliciter les ressources réseau si l'image est dans le cache.
    let imageSession: URLSession
    
    init() {
        self.country = ""
        // print(url + "&apiKey=" + apiKey)
        initURL = URL(string: url + country + "&apiKey=" + apiKey)!
        
        // Configuration d'URLSession
        let config = URLSessionConfiguration.default
        imageSession = URLSession(configuration: config)
    }
    
    func initializeLocalNews(country: String = "fr", completion: @escaping (Result<[Article], NewsAPIError>) -> ()) {
        self.country = country
        initURL = URL(string: url + country + "&apiKey=" + apiKey)!
        // print(initURL.absoluteString)
        getNewsAlamofire(url: initURL, completion: completion)
    }
    
    func searchNews(language: String = "fr", query: String, completion: @escaping (Result<[Article], NewsAPIError>) -> ()) {
        let searchUrl = "https://newsapi.org/v2/everything?language=\(language)&q=\(query)&apiKey=" + apiKey
        getNewsAlamofire(url: URL(string: searchUrl)!, completion: completion)
    }
    
    func searchCountryLocalNews(query: String, completion: @escaping (Result<[Article], NewsAPIError>) -> ()) {
        let searchUrl = "https://newsapi.org/v2/everything?country=\(country)&q=\(query)&apiKey=" + apiKey
        getNewsAlamofire(url: URL(string: searchUrl)!, completion: completion)
    }
    
    func getNews(url: URL, completion: @escaping (Result<[Article], NewsAPIError>) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Erreur réseau
            guard error == nil else {
                print(error?.localizedDescription ?? "ERREUR")
                completion(.failure(.networkError))
                
                return
            }
            
            // Pas de réponse du serveur
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.apiError))
                
                return
            }
            
            // print("Code: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            // Code 200, vérifions si les données existent
            case (200...299):
                if let data = data {
                    var output: ArticleOutput?
                    
                    do {
                        output = try JSONDecoder().decode(ArticleOutput.self, from: data)
                    } catch {
                        completion(.failure(.decodeError))
                        return
                    }
                    
                    if let newsData = output?.articles  {
                        // print("Articles disponibles: \(newsData.count)")
                        completion(.success(newsData))
                    }
                } else {
                    completion(.failure(.downloadError))
                }
            case 400:
                completion(.failure(.parametersMissing))
            case 401:
                completion(.failure(.invalidApiKey))
            case 404:
                completion(.failure(.notFound))
            case 500:
                completion(.failure(.serverError))
            default:
                completion(.failure(.unknown))
            }
        }
        task.resume()
    }
    
    func getNewsAlamofire(url: URL, completion: @escaping (Result<[Article], NewsAPIError>) -> ()) {
        AF.request(url).validate().responseDecodable(of: ArticleOutput.self) { response in
            switch response.result {
                case .success:
                guard let data = response.value else {
                    completion(.failure(.downloadError))
                    
                    return
                }
                
                if let newsData = data.articles {
                    // print("Articles disponibles: \(newsData.count)")
                    completion(.success(newsData))
                }
                    
                case let .failure(error):
                guard let httpResponse = response.response else {
                    print("ERREUR: \(error)")
                    return
                }
                
                switch httpResponse.statusCode {
                    case 400:
                        completion(.failure(.parametersMissing))
                    case 401:
                        completion(.failure(.invalidApiKey))
                    case 404:
                        completion(.failure(.notFound))
                    case 500:
                        completion(.failure(.serverError))
                    default:
                        completion(.failure(.unknown))
                }
            }
        }
    }
    
    func downloadImage(with imageURL: URL, completion: @escaping (Result<Data, NewsAPIError>) -> (Void)) {
        // Si l'image en question existe déjà dans le cache
        if let imageData = images.object(forKey: imageURL.absoluteString as NSString) {
            completion(.success(imageData as Data))
            
            // print("Image en cache: \(imageURL.absoluteString)")
            // Le retour explicite va permettre de ne pas aller plus loin pour afficher l'image depuis la mémoire interne
            return
        }
        
        // La tâche asynchrone en tâche de fond va gérer le téléchargement des données de l'image
        let task = imageSession.downloadTask(with: imageURL) { localUrl, response, error in
            if error != nil {
                completion(.failure(.downloadError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError))
                return
            }

            guard let localUrl = localUrl else {
                completion(.failure(.parametersMissing))
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(.success(data))
            } catch _ {
                completion(.failure(.decodeError))
            }
        }

        task.resume()
    }
}
