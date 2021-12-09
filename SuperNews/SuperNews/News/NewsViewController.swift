//
//  NewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import Combine

class NewsViewController: UIViewController {
    
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var newsAvailabilityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @Published private(set) var searchQuery = ""
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel = NewsViewModel()
    
    var countryCode = ""
    var languageCode = ""
    var languageName = "" {
        didSet {
            
        }
    }
    // let newsAPI = NewsAPIService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCountryAndLanguage()
        setTableView()
        setSearchBar()
        setBindings()
    }
    
    // Lorsque la vue est affichée, se déclenche à chaque fois que l'utilisateur se rend sur cette vue
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // L'utilisateur a choisi une langue différente dans les paramètres.
        if let language = UserDefaults.standard.string(forKey: "languageCode"), let name = UserDefaults.standard.string(forKey: "languageName"), name != languageName && language != languageCode {
            viewModel.languageCode = language
            viewModel.languageName = name
        }
        
        // L'utilisateur a choisi un pays différent dans les paramètres.
        if let code = UserDefaults.standard.string(forKey: "countryCode"), code != countryCode {
            viewModel.countryCode = code
            /*
             articleTableView.isHidden = true
             spinner.startAnimating()
             spinner.isHidden = false
             */
            print("\(code) != \(countryCode)")
        }
        
        viewModel.initNews()
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
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
        searchBar.backgroundImage = UIImage() // Supprimer le fond par défaut
        searchBar.showsCancelButton = false
        searchBar.delegate = self
    }
    
    private func displayNoResult() {
        articleTableView.isHidden = true
        newsAvailabilityLabel.isHidden = false
        newsAvailabilityLabel.text = "Aucun résultat pour \"\(searchQuery)\". Veuillez réessayer avec une autre recherche."
    }
    
    private func loadCountryAndLanguage() {
        viewModel.countryCode = UserDefaults.standard.string(forKey: "countryCode") ?? "fr"
        viewModel.languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "fr"
        viewModel.languageName = UserDefaults.standard.string(forKey: "languageName") ?? "Français"
    }
    
    private func updateTableView() {
        newsAvailabilityLabel.isHidden = true
        articleTableView.isHidden = false
        articleTableView.reloadData()
    }
    
    private func setBindings() {
        func setSearchBinding() {
            $searchQuery
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    print(value)
                    self?.viewModel.searchQuery = value
                }.store(in: &subscriptions)
        }
        
        func setCountryBinding() {
            viewModel.$languageName
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    print(value)
                    self?.searchBar.placeholder = "Recherche (langue: \(value))"
                }.store(in: &subscriptions)
        }
        
        func setUpdateBinding() {
            viewModel.updateResult
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
            viewModel.isLoading
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
        setSearchBinding()
        setUpdateBinding()
        setLoadingBinding()
    }
}

/*
 extension NewsViewController: UITextFieldDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 searchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
 
 guard let search = searchBar.text, !search.isEmpty else {
 return false
 }
 
 let query = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
 articles.removeAll()
 spinner.startAnimating()
 spinner.isHidden = false
 articleTableView.isHidden = true
 
 newsAPI.searchNews(language: languageCode, query: query!) { [weak self] result in
 switch result {
 case .success(let newsData):
 self?.articles = newsData
 // Mise à jour au niveau visuel dans la propriété observée didSet de articles.
 case .failure(_):
 print("Pas de données")
 }
 }
 
 return true
 }
 }
 */

extension NewsViewController: UITableViewDataSource {
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsViewModels.count
        // return articles.count
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
        self.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchQuery = ""
        self.searchBar.text = ""
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        self.searchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
}

extension NewsViewController: UITableViewDelegate {
    /*
    // Au clic sur la ligne de la liste
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "newsSegue", sender: self)
    }
    
    // De la cellule, on transite vers le ViewController de l'article en transférant les données de la cellule
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? ArticleViewController{
            // On vérifie que le contenu de l'article existe
            guard let index = articleTableView.indexPathForSelectedRow?.row else {
                return
            }
            
            // On extrait le contenu de la cellule
            let cell = articleTableView.cellForRow(at: articleTableView.indexPathForSelectedRow!) as! NewsTableViewCell
            
            // On envoie au ViewController les données de l'article
            destination.article = articles[index]
            destination.image = cell.articleImage.image! // Extraction de l'image du TableViewCell (on évite de refaire un téléchargement asynchrone).
        }
    }
    */
}
