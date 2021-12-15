//
//  CountryNewsViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 21/04/2021.
//

import UIKit
import Combine

class CountryNewsViewController: UIViewController {
    @IBOutlet weak var articleTableView: UITableView!
    @IBOutlet weak var countryNewsLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @Published private(set) var searchQuery = ""
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: CountryNewsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setBindings()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        articleTableView.isHidden = true
        spinner.isHidden = true
    }
    
    // Injection de dépendance
    func configure(code: String, name: String) {
        viewModel = CountryNewsViewModel(countryCode: code, countryName: name)
    }
}

// MARK: - Fonctions pour la gestion des vues et des liens avec la vue modèle
extension CountryNewsViewController {
    private func setTableView() {
        // Configuration TableView
        articleTableView.isHidden = true
        articleTableView.dataSource = self
        articleTableView.delegate = self
    }
    
    private func updateTableView() {
        articleTableView.isHidden = false
        articleTableView.reloadData()
    }
    
    private func showAlertError(errorMessage: String) {
        // On affiche une alerte
        let alert = UIAlertController(title: "Erreur", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func displayNoResult() {
        articleTableView.isHidden = true
        // On affiche une alerte
        let alert = UIAlertController(title: "Erreur", message: "Aucun article disponible pour le pays: \(viewModel.countryName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func setBindings() {
        func setCountryBinding() {
            viewModel.$countryName
                .receive(on: DispatchQueue.main)
                .compactMap { "Pays des news: \($0)" }
                .assign(to: \.text, on: countryNewsLabel)
                .store(in: &subscriptions)
        }
        
        func setUpdateBinding() {
            viewModel.updateResult
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print("Erreur reçue: \(error.rawValue)")
                        self?.showAlertError(errorMessage: error.rawValue)
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
                        self?.spinner.isHidden = false
                        self?.spinner.startAnimating()
                        self?.articleTableView.isHidden = true
                    }
                }.store(in: &subscriptions)
        }
        // L'intérêt d'utiliser des fonctions imbriquées est de pouvoir respecter le 1er prinicipe du SOLID étant le principe de responsabilité unique (SRP: Single Responsibility Principle)
        setCountryBinding()
        setUpdateBinding()
        setLoadingBinding()
    }
}

extension CountryNewsViewController: UITableViewDataSource {
    // Nombre d'articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsViewModels.count
    }
    
    // Cellule à utiliser pour le TableView, avec les données téléchargées.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = articleTableView.dequeueReusableCell(withIdentifier: "localNewsCell") as! NewsTableViewCell
        
        newsCell.configuration(with: viewModel.newsViewModels[indexPath.row])
        return newsCell
    }
}

extension CountryNewsViewController: UITableViewDelegate {
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
