//
//  SettingChoiceCellViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/12/2021.
//

import Foundation

final class SettingChoiceCellViewModel {
    let code: String
    let name: String
    let flagCode: String
    let type: String
    
    init(code: String, name: String, flagCode: String, type: String) {
        self.code = code
        self.name = name
        self.flagCode = flagCode
        self.type = type
    }
}
