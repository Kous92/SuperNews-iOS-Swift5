//
//  SettingsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        let nib = UINib(nibName: "settingsTableViewSection", bundle: nil)
        settingsTable.register(nib, forHeaderFooterViewReuseIdentifier: "customHeader")
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.settingsTable.dequeueReusableHeaderFooterView(withIdentifier: "customHeader") as! SettingsHeaderView
        header.title.text = "Langue et pays"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = settingsTable.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingTableViewCell
        let setting = SettingsSection(rawValue: indexPath.row)
        
        switch setting {
        case .NewsCountry:
            settingsCell.settingContent.text = "Pays des news"
            settingsCell.settingType = "country"
        case .NewsLanguage:
            settingsCell.settingContent.text = "Langue des news"
            settingsCell.settingType = "language"
        case .none:
            break
        }
        
        return settingsCell
    }
    
    // Au clic sur la ligne de la liste
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "settingSegue", sender: self)
        // Déselectionner la cellule, doit être fait après le segue pour éviter le crash.
        settingsTable.deselectRow(at: indexPath, animated: false)
    }
    
    // De la cellule, on transite vers le ViewController de l'article en transférant les données de la cellule
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? SettingsSelectionViewController {
            // On extrait le contenu de la cellule
            let cell = settingsTable.cellForRow(at: settingsTable.indexPathForSelectedRow!) as! SettingTableViewCell
            
            // On envoie au ViewController les données de l'article
            destination.settingType = cell.settingType
        }
    }
}
