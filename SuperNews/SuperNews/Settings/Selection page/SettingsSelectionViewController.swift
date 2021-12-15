//
//  SettingsSelectionViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 03/05/2021.
//

import UIKit
import Combine

final class SettingsSelectionViewController: UIViewController {
    var settingType = ""
    @IBOutlet weak var settingsChoiceTable: UITableView!
    @IBOutlet weak var settingLabel: UILabel!
    var viewModel: SettingsSelectionViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setBinding()
    }
    
    // Injection de dépendance
    func configure(with type: String) {
        self.viewModel = SettingsSelectionViewModel(with: type)
        self.viewModel.initData()
    }
    
    private func setTableView() {
        settingsChoiceTable.delegate = self
        settingsChoiceTable.dataSource = self
    }
    
    private func setBinding() {
        viewModel.updateResult
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("OK: terminé")
                case .failure(let error):
                    print("Erreur reçue: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] updated in
                if updated {
                    self?.settingsChoiceTable.reloadData()
                }
            }.store(in: &subscriptions)
    }
}

extension SettingsSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Cellules: \(viewModel.settingsCellViewModels.count)")
        return viewModel.settingsCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsChoiceTable.dequeueReusableCell(withIdentifier: "settingsChoice") as? SettingChoiceTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configuration(with: viewModel.settingsCellViewModels[indexPath.row])
        
        // Vérification si un pays ou un langage précédemment séléctionné a été sauvegardé, si c'est le cas, un coche apparaîtra dans la cellule
        switch viewModel.settingType {
        case "language":
            if viewModel.checkSelectedLanguage(with: viewModel.settingsCellViewModels[indexPath.row].code, at: indexPath.row) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case "country":
            if viewModel.checkSelectedCountry(with: viewModel.settingsCellViewModels[indexPath.row].code, at: indexPath.row) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row.
        settingsChoiceTable.deselectRow(at: indexPath, animated: false)
        
        // Did the user tap on a selected filter item? If so, do nothing.
        let selected = indexPath.row
        if selected == viewModel.actualSelectedIndex {
            return
        }
        
        // Remove the checkmark from the previously selected filter item.
        if let previousCell = tableView.cellForRow(at: IndexPath(row: viewModel.actualSelectedIndex, section: indexPath.section)) {
            previousCell.accessoryType = .none
        }
        
        // Mark the newly selected filter item with a checkmark.
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // Remember this selected filter item.
        viewModel.actualSelectedIndex = selected
        
        // Sauvegarde du paramètre avec userDefaults, les changements s'appliqueront dans NewsViewController
        switch viewModel.settingsCellViewModels[selected].type {
        case "language":
            viewModel.saveLanguage(with: viewModel.settingsCellViewModels[selected].name, and: viewModel.settingsCellViewModels[selected].code)
        case "country":
            viewModel.saveCountry(with: viewModel.settingsCellViewModels[selected].code)
        default:
            break
        }
    }
}
