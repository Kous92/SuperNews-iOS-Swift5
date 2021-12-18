//
//  SettingChoiceTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import UIKit

final class SettingChoiceTableViewCell: UITableViewCell {
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    var viewModel: SettingChoiceCellViewModel!
    
    // Injection de dépendance
    func configuration(with viewModel: SettingChoiceCellViewModel) {
        self.viewModel = viewModel
        countryImage.image = UIImage(named: viewModel.flagCode)
        countryNameLabel.text = viewModel.name
    }
}
