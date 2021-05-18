//
//  NewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var newsAvailabilityLabel: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    
    var articles = [Article]() {
        didSet {
            // On met à jour la liste d'articles de façon asynchrone (dans le thread principal), les données étant récupérée dans un thread de fond.
            DispatchQueue.main.async { [weak self] in
                self?.articleTableView.reloadData()
                if let articles = self?.articles, articles.count > 0 {
                    self?.articleTableView.isHidden = false
                    self?.newsAvailabilityLabel.isHidden = true
                } else {
                    self?.articleTableView.isHidden = true
                    self?.newsAvailabilityLabel.isHidden = false
                    self?.newsAvailabilityLabel.text = "Aucune news disponible"
                }
            }
        }
    }
    
    var countryCode = ""
    var languageCode = ""
    var languageName = "" {
        didSet {
            searchBar.attributedPlaceholder = NSAttributedString(string: "Rechercher (langue: \(languageName))", attributes: [.foregroundColor: UIColor.label])
        }
    }
    let newsAPI = NewsAPIService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        
        countryCode = UserDefaults.standard.string(forKey: "countryCode") ?? "fr"
        languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "fr"
        languageName = UserDefaults.standard.string(forKey: "languageName") ?? "Français"
        
        if articles.count < 1 {
            articleTableView.isHidden = true
            newsAvailabilityLabel.isHidden = false
            newsAvailabilityLabel.text = "La langue des news est en \(languageName). Le contenu recherché sera affiché dans la langue définie. Pour obtenir les news locales d'un pays, rendez-vous dans la carte du monde puis choisissez un pays en cliquant sur son drapeau puis sur \"i\" dans l'info-bulle."
        }
        
        newsAPI.initializeLocalNews(country: countryCode, completion: { [weak self] result in
            switch result {
            case .success(let newsData):
                // Mise à jour au niveau visuel dans la propriété observée didSet de articles.
                self?.articles = newsData
            case .failure(_):
                self?.articles.removeAll()
                print("Pas de données")
            }
        })
    }
    
    // Lorsque la vue est affichée, se déclenche à chaque fois que l'utilisateur se rend sur cette vue
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // L'utilisateur a choisi un pays différent dans les paramètres.
        if let code = UserDefaults.standard.string(forKey: "countryCode"), code != countryCode {
            print("\(code) != \(countryCode)")
            // On refait une requête si le pays est différent
            newsAPI.initializeLocalNews(country: code, completion: { [weak self] result in
                switch result {
                case .success(let newsData):
                    // Mise à jour au niveau visuel dans la propriété observée didSet de articles.
                    self?.articles = newsData
                case .failure(_):
                    self?.articles.removeAll()
                    print("Pas de données")
                }
            })
            
            countryCode = code
        }
        
        // L'utilisateur a choisi une langue différent dans les paramètres.
        if let language = UserDefaults.standard.string(forKey: "languageCode"), let name = UserDefaults.standard.string(forKey: "languageName"), name != languageName && language != languageCode {
            languageCode = language
            languageName = name
        }
    }
}

extension NewsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        
        guard let search = searchBar.text, !search.isEmpty else {
            return false
        }
        
        let query = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        articles.removeAll()
        
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
    
    /*
    // Dès qu'on a cliqué sur la barre de recherche
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        // print(searchBar.text!)
        
        guard let search = searchBar.text, !search.isEmpty else {
            return
        }
        
        let query = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        articles.removeAll()
        
        newsAPI.searchNews(language: languageCode, query: query!) { [weak self] result in
            switch result {
            case .success(let newsData):
                self?.articles = newsData
                // Mise à jour au niveau visuel dans la propriété observée didSet de articles.
            case .failure(_):
                print("Pas de données")
            }
        }
    }
 */
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    // Cellule à utiliser pour le TableView, avec les données téléchargées.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsCell = articleTableView.dequeueReusableCell(withIdentifier: "newsCell") as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        newsCell.configuration(with: articles[indexPath.row])
        
        return newsCell
    }
    
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
}
