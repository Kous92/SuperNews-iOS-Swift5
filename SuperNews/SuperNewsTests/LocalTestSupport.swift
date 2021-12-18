//
//  LocalTestSupport.swift
//  SuperNewsTests
//
//  Created by Koussaïla Ben Mamar on 16/12/2021.
//

import Foundation
@testable import SuperNews

func loadLocalData(with source: String) -> Article? {
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
        
        if let data = output.articles {
            return data[0]
        }
    } catch {
        print("ERREUR: \(error)")
    }
    
    return nil
}
