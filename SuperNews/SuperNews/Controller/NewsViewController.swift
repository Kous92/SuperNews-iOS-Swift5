//
//  NewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var articles = [Article]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.articleTableView.reloadData()
            }
        }
    }
    
    let newsAPI = NewsAPIService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        
        newsAPI.initializeLocalNews { [weak self] result in
            switch result {
            case .success(let newsData):
                self?.articles = newsData
                DispatchQueue.main.async {
                    self?.articleTableView.reloadData()
                }
            case .failure(_):
                print("Pas de données")
            }
        }
    }
}

extension NewsViewController: UISearchBarDelegate {
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
        
        newsAPI.searchNews(query: query!) { [weak self] result in
            switch result {
            case .success(let newsData):
                self?.articles = newsData
                // Mise à jour au niveau visuel dans la propriété observée didSet de articles.
                /*
                DispatchQueue.main.async {
                    self?.articleTableView.reloadData()
                }*/
            case .failure(_):
                print("Pas de données")
            }
        }
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    // Cellule à utiliser pour le TableView, avec les données téléchargées.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = articleTableView.dequeueReusableCell(withIdentifier: "newsCell") as! NewsTableViewCell
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
