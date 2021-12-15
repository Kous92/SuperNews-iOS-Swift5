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
    
    // Injection de dépendance
    func configuration(with viewModel: CountryCellViewModel) {
        countryImage.image = UIImage(named: viewModel.countryCode)
        countryNameLabel.text = viewModel.countryName
    }

}
