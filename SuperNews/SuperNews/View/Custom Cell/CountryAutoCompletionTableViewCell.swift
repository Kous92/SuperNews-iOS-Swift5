//
//  CountryAutoCompletionTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 17/05/2021.
//

import UIKit

class CountryAutoCompletionTableViewCell: UITableViewCell {

    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    var country: Country?
    
    func configuration(country: Country) {
        self.country = country
        // print(self.country)
        countryImage.image = UIImage(named: country.countryCode)
        countryNameLabel.text = country.countryName
    }

}
