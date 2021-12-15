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
}
