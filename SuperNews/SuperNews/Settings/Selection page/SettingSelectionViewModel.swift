//
//  SettingSelectionViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/12/2021.
//

import Foundation
import Combine

final class SettingsSelectionViewModel {
    private var countries = [Country]()
    private var languages = [Language]()
    var actualSelectedIndex = 0
    var settingsCellViewModels = [SettingChoiceCellViewModel]()
    var settingType: String
    
    // Les sujets, ceux qui émettent et reçoivent des événements
    var updateResult = PassthroughSubject<Bool, LocalServiceError>()
    
    init(with settingType: String) {
        self.settingType = settingType
    }
    
    func initData() {
        switch settingType {
        case "language":
            initializeLanguageData()
        case "country":
            initializeCountryData()
        default:
            break
        }
    }
    
    private func initializeCountryData() {
        if let data = getLocalCountryData() {
            countries = data
            countries.forEach { settingsCellViewModels.append(SettingChoiceCellViewModel(code: $0.countryCode, name: $0.countryName, flagCode: $0.countryCode, type: "country")) }
            updateResult.send(true)
        } else {
            updateResult.send(completion: .failure(.noCountries))
        }
    }
    
    private func initializeLanguageData() {
        if let data = getLocalLanguageData() {
            languages = data
            languages.forEach { settingsCellViewModels.append(SettingChoiceCellViewModel(code: $0.languageCode, name: $0.languageName, flagCode: $0.languageDefaultFlag, type: "language")) }
            updateResult.send(true)
        } else {
            updateResult.send(completion: .failure(.noLanguage))
        }
    }
    
    // Vérification si un pays précédemment séléctionné a été sauvegardé
    func checkSelectedCountry(with country: String, at index: Int) -> Bool {
        if let savedCountrySetting = UserDefaults.standard.string(forKey: "countryCode"), savedCountrySetting == country {
            print("Chargé: \(savedCountrySetting)")
            actualSelectedIndex = index
            
            return true
        }
        
        return false
    }
    
    // Vérification si une langue précédemment séléctionnée a été sauvegardée
    func checkSelectedLanguage(with language: String, at index: Int) -> Bool {
        print("Disponible: \(UserDefaults.standard.string(forKey: "languageCode") ?? "Rien") -> Vérification avec: \(language)")
        if let savedLanguageSetting = UserDefaults.standard.string(forKey: "languageCode"), savedLanguageSetting == language {
            print("Chargé: \(savedLanguageSetting)")
            actualSelectedIndex = index
            
            return true
        }
        
        return false
    }
    
    func saveLanguage(with name: String, and code: String) {
        UserDefaults.standard.setValue(name, forKey: "languageName")
        UserDefaults.standard.setValue(code, forKey: "languageCode")
    }
    
    func saveCountry(with code: String) {
        UserDefaults.standard.setValue(code, forKey: "countryCode")
    }
}
