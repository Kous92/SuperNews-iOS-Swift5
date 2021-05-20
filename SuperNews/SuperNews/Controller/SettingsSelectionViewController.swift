//
//  SettingsSelectionViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import UIKit

class SettingsSelectionViewController: UIViewController {
    var settingType = ""
    @IBOutlet weak var settingsChoiceTable: UITableView!
    @IBOutlet weak var settingLabel: UILabel!
    var actualSelectedIndex = 0
    
    var countries = [Country]()
    var languages = [Language]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print(settingType)
        
        switch settingType {
        case "country":
            settingLabel.text = "Pays des news"
            initializeCountryData()
        case "language":
            settingLabel.text = "Langue des news"
            initializeLanguageData()
        default:
            break
        }
        settingsChoiceTable.delegate = self
        settingsChoiceTable.dataSource = self
    }
    
    private func initializeCountryData() {
        let countryData = getLocalCountryData()
        
        if let data = countryData {
            countries = data
        }
    }
    
    private func initializeLanguageData() {
        let languageData = getLocalLanguageData()
        
        if let data = languageData {
            languages = data
        }
    }
}

extension SettingsSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch settingType {
        case "language":
            return languages.count
        case "country":
            return countries.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsChoiceTable.dequeueReusableCell(withIdentifier: "settingsChoice") as! SettingChoiceTableViewCell
        
        switch settingType {
        case "language":
            cell.configuration(language: languages[indexPath.row])
            
            if let savedLanguageSetting = UserDefaults.standard.string(forKey: "languageCode"), savedLanguageSetting == languages[indexPath.row].languageCode {
                print("Chargé: \(savedLanguageSetting)")
                cell.accessoryType = .checkmark
                actualSelectedIndex = indexPath.row
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        case "country":
            cell.configuration(country: countries[indexPath.row])
            
            if let savedCountrySetting = UserDefaults.standard.string(forKey: "countryCode"), savedCountrySetting == countries[indexPath.row].countryCode {
                print("Chargé: \(savedCountrySetting)")
                cell.accessoryType = .checkmark
                actualSelectedIndex = indexPath.row
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row.
        settingsChoiceTable.deselectRow(at: indexPath, animated: false)
        
        // Did the user tap on a selected filter item? If so, do nothing.
        let selected = indexPath.row
        if selected == actualSelectedIndex {
            return
        }

        // Remove the checkmark from the previously selected filter item.
        if let previousCell = tableView.cellForRow(at: IndexPath(row: actualSelectedIndex, section: indexPath.section)) {
            previousCell.accessoryType = .none
        }
        
        // Mark the newly selected filter item with a checkmark.
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // Remember this selected filter item.
        actualSelectedIndex = selected
        
        // Sauvegarde du paramètre avec userDefaults
        switch settingType {
        case "language":
            UserDefaults.standard.setValue(languages[indexPath.row].languageCode, forKey: "languageCode")
            UserDefaults.standard.setValue(languages[indexPath.row].languageName, forKey: "languageName")
        case "country":
            UserDefaults.standard.setValue(countries[indexPath.row].countryCode, forKey: "countryCode")
        default:
            break
        }
    }
}
