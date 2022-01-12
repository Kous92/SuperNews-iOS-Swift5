//
//  NewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var newsAvailabilityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = NewsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setSearchBar()
        setBindings()
        viewModel.loadCountryAndLanguage()
        viewModel.initNews()
    }
    
    // Lorsque la vue est affichée, se déclenche à chaque fois que l'utilisateur se rend sur cette vue
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // L'utilisateur a choisi une langue différente dans les paramètres.
        viewModel.checkCountry()
        
        // L'utilisateur a choisi un pays différent dans les paramètres.
        viewModel.checkLanguage()
    }
}

// MARK: - Fonctions pour la gestion des vues et des liens avec la vue modèle
extension NewsViewController {
    private func setTableView() {
        // Configuration TableView
        articleTableView.isHidden = true
        articleTableView.dataSource = self
        articleTableView.delegate = self
    }
    
    private func setSearchBar() {
        // Configuration barre de recherche
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Annuler"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .label
        searchBar.backgroundImage = UIImage() // Supprimer le fond par défaut
        searchBar.showsCancelButton = false
        searchBar.delegate = self
    }
    
    private func displayNoResult() {
        articleTableView.isHidden = true
        newsAvailabilityLabel.isHidden = false
        newsAvailabilityLabel.text = "Aucun résultat pour \"\(viewModel.searchQuery)\". Veuillez réessayer avec une autre recherche."
    }
    
    private func updateTableView() {
        newsAvailabilityLabel.isHidden = true
        articleTableView.isHidden = false
        articleTableView.reloadData()
    }
    
    private func setBindings() {
        func setLanguageBinding() {
            viewModel.languagePublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    print(value)
                    self?.searchBar.placeholder = "Recherche (langue: \(value))"
                }.store(in: &subscriptions)
        }
        
        func setUpdateBinding() {
            viewModel.updateResultPublisher
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print("Erreur reçue: \(error.rawValue)")
                    }
                } receiveValue: { [weak self] updated in
                    self?.spinner.stopAnimating()
                    self?.spinner.isHidden = true
                    
                    if updated {
                        self?.updateTableView()
                    } else {
                        self?.displayNoResult()
                    }
                }.store(in: &subscriptions)
        }
        
        func setLoadingBinding() {
            viewModel.isLoadingPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] isLoading in
                    if isLoading {
                        self?.spinner.startAnimating()
                        self?.spinner.isHidden = false
                        self?.articleTableView.isHidden = true
                    }
                }.store(in: &subscriptions)
        }
        // L'intérêt d'utiliser des fonctions imbriquées est de pouvoir respecter le 1er prinicipe du SOLID étant le principe de responsabilité unique (SRP: Single Responsibility Principle)
        setLoadingBinding()
        setUpdateBinding()
        setLanguageBinding()
    }
}

extension NewsViewController: UITableViewDataSource {
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsViewModels.count
    }
    
    // Cellule à utiliser pour le TableView, avec les données téléchargées.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsCell = articleTableView.dequeueReusableCell(withIdentifier: "newsCell") as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        newsCell.configuration(with: viewModel.newsViewModels[indexPath.row])
        
        return newsCell
    }
}

extension NewsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true) // Afficher le bouton d'annulation
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.searchQuery = ""
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        viewModel.initNews()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        self.searchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let articleViewController = storyboard?.instantiateViewController(withIdentifier: "articleViewController") as? ArticleViewController else {
            fatalError("Le ViewController n'est pas détecté dans le Storyboard.")
        }
        
        articleTableView.deselectRow(at: indexPath, animated: true)
        articleViewController.configure(with: ArticleViewModel(article: viewModel.newsViewModels[indexPath.row].article))
        articleViewController.modalPresentationStyle = .fullScreen
        present(articleViewController, animated: true, completion: nil)
    }
}
