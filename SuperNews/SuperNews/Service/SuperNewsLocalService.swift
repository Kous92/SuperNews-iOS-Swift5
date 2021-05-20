//
//  SuperNewsLocalService.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 20/05/2021.
//

import Foundation

func getLocalCountryData() -> [Country]? {
    // Vérification de l'existence du fichier local countries.json
    guard let path = Bundle.main.path(forResource: "countries", ofType: "json") else {
        return nil
    }
    
    let url = URL(fileURLWithPath: path)
    var countryList: Countries?
    
    do {
        // Récupération des données JSON en type Data
        let data = try Data(contentsOf: url)
        
        // Décodage des données JSON en objets exploitables
        countryList = try JSONDecoder().decode(Countries.self, from: data)
        
        if let result = countryList {
            // print(result.countries.count)
            let countries = result.countries.sorted { $0.countryName < $1.countryName }
            return countries
        } else {
            print("Échec lors du décodage des données")
        }
    } catch {
        print("ERREUR: \(error)")
    }
    
    return nil
}

func getLocalLanguageData() -> [Language]? {
    // Vérification de l'existence du fichier local countries.json
    guard let path = Bundle.main.path(forResource: "language", ofType: "json") else {
        return nil
    }
    
    let url = URL(fileURLWithPath: path)
    var languageList: Languages?
    
    do {
        // Récupération des données JSON en type Data
        let data = try Data(contentsOf: url)
        
        // Décodage des données JSON en objets exploitables
        languageList = try JSONDecoder().decode(Languages.self, from: data)
        
        if let result = languageList {
            // print(result.countries.count)
            let languages = result.language.sorted { $0.languageName < $1.languageName }
            return languages
        } else {
            print("Échec lors du décodage des données")
        }
    } catch {
        print("ERREUR: \(error)")
    }
    
    return nil
}

func getTodayTime() -> String {
    var currentTime: Date {
        return Date()
    }
    
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.locale = Locale(identifier: "FR-fr")
    
    return formatter.string(from: currentTime as Date)
}


func getTodayDate() -> String {
    var currentTime: Date {
        return Date()
    }
    
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.locale = Locale(identifier: "FR-fr")
    
    return formatter.string(from: currentTime as Date).capitalized
}
