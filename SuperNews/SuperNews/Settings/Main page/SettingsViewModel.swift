//
//  SettingsViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/12/2021.
//

import Foundation

final class SettingsViewModel {
    let sections = SettingsSection.allCases.count
    
    func getSettingSection(with index: Int) -> SettingsSection? {
        if let section = SettingsSection(rawValue: index) {
            return section
        }
        
        return nil
    }
    
    func resetSettings() {
        // Réinitialisation aux paramètres par défaut
        UserDefaults.standard.setValue("Français", forKey: "languageName")
        UserDefaults.standard.setValue("fr", forKey: "languageCode")
        UserDefaults.standard.setValue("fr", forKey: "countryCode")
    }
}
