//
//  SettingTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import UIKit

final class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var settingContent: UILabel!
    var settingType = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
