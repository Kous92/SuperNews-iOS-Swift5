//
//  SettingsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTable: UITableView!
    var viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
}

extension SettingsViewController {
    private func setTableView() {
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        let nib = UINib(nibName: "settingsTableViewSection", bundle: nil)
        settingsTable.register(nib, forHeaderFooterViewReuseIdentifier: "customHeader")
    }
}

extension SettingsViewController: UITableViewDataSource {
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
        return viewModel.sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingsCell = settingsTable.dequeueReusableCell(withIdentifier: "settingsCell") as? SettingTableViewCell,
              let setting = viewModel.getSettingSection(with: indexPath.row) else {
                  return UITableViewCell()
              }
        
        
        settingsCell.settingContent.text = setting.detail
        settingsCell.settingType = setting.description
        
        return settingsCell
    }
}

extension SettingsViewController: UITableViewDelegate {
    // Au clic sur la ligne de la liste
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsTable.deselectRow(at: indexPath, animated: false)
        
        guard let settingType = viewModel.getSettingSection(with: indexPath.row) else {
            fatalError("Le type de paramètre sélectionné n'existe pas")
        }
        
        // Si on veut réinitialiser les paramètres
        if settingType == .NewsReset {
            let alert = UIAlertController(title: "Attention", message: "Voulez-vous réinitialiser les paramètres des news favorites et de la langue de recherche des news ? Si oui, les paramètres seront réinitialisés par défaut.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { [weak self] _ in
                self?.viewModel.resetSettings()
            }))
            alert.addAction(UIAlertAction(title: "Non", style: .cancel))
            self.present(alert, animated: true)
            
            return
        }
        
        // Si on choisit de changer la langue de recherche ou bien le pays favori.
        guard let settingsSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "settingsSelectionViewController") as? SettingsSelectionViewController else {
            fatalError("Le ViewController n'est pas détecté dans le Storyboard.")
        }
        
        print("Paramètre sélectionné: \(settingType.detail) -> type: \(settingType.description)")
        settingsSelectionViewController.configure(with: settingType.description)
        present(settingsSelectionViewController, animated: true, completion: nil)
    }
}
