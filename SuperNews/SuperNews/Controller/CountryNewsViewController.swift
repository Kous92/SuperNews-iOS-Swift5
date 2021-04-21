//
//  CountryNewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 21/04/2021.
//

import UIKit

class CountryNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countryNewsLabel: UILabel!
    
    var countryArticles = [Article]()
    let newsAPI = NewsAPIService.shared
    var countryCode = ""
    var countryName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryNewsLabel.text = "Pays des news: \(countryName)"
        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        
        print("CountryCode = \(countryCode)")
        print("CountryCode = \(countryName)")
        
        newsAPI.country = countryCode
        /*
        newsAPI.initializeLocalNews(country: countryCode) { [weak self] result in
            switch result {
            case .success(let newsData):
                self?.countryArticles = newsData
                // print(newsData)
                DispatchQueue.main.async {
                    self?.articleTableView.reloadData()
                }
            case .failure(_):
                print("Pas de données")
            }
        }
 */
    }
    
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryArticles.count
    }
    
    // Cellule à utiliser pour le TableView, avec les données téléchargées.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = articleTableView.dequeueReusableCell(withIdentifier: "localNewsCell") as! NewsTableViewCell
        // print(countryArticles[indexPath.row])
        newsCell.configuration(with: countryArticles[indexPath.row])
        
        return newsCell
    }
    
    // Au clic sur la ligne de la liste
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "countryArticleSegue", sender: self)
    }
    
    // De la cellule, on transite vers le ViewController de l'article en transférant les données de la cellule
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? ArticleViewController{
            // On vérifie que le contenu de l'article existe
            guard let index = articleTableView.indexPathForSelectedRow?.row else {
                return
            }
            
            // On extrait le contenu de la cellule
            let cell = articleTableView.cellForRow(at: articleTableView.indexPathForSelectedRow!) as! NewsTableViewCell
            
            // On envoie au ViewController les données de l'article
            destination.article = countryArticles[index]
            destination.image = cell.articleImage.image! // Extraction de l'image du TableViewCell (on évite de refaire un téléchargement asynchrone).
        }
    }
    
    // Dès qu'on a cliqué sur la barre de recherche
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        print(searchBar.text!)
        
        guard let search = searchBar.text, !search.isEmpty else {
            return
        }
        
        let query = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        countryArticles.removeAll()
        
        newsAPI.searchNews(query: query!) { [weak self] result in
            switch result {
            case .success(let newsData):
                self?.countryArticles = newsData
                DispatchQueue.main.async {
                    self?.articleTableView.reloadData()
                }
            case .failure(_):
                print("Pas de données")
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
