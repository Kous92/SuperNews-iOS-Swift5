//
//  SettingChoiceTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import UIKit

class SettingChoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    var isChosen: Bool = false
    var country: Country?
    var language: Language?
    
    func configuration(country: Country) {
        self.country = country
        countryImage.image = UIImage(named: country.countryCode)
        countryNameLabel.text = country.countryName
    }
    
    func configuration(language: Language) {
        self.language = language
        countryImage.image = UIImage(named: language.languageDefaultFlag)
        countryNameLabel.text = language.languageName
    }
}
