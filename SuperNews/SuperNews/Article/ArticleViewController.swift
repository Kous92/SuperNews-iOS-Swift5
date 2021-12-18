//
//  ArticleViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/04/2021.
//

import UIKit
import Combine
import Kingfisher
import SafariServices

final class ArticleViewController: UIViewController {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articlePublishDateLabel: UILabel!
    @IBOutlet weak var articleAuthorLabel: UILabel!
    @IBOutlet weak var articleContentLabel: UILabel!
    @IBOutlet weak var articleSourceLabel: UILabel!
    
    private var viewModel: ArticleViewModel!
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
    }
    
    // Injection de dépendance
    func configure(with viewModel: ArticleViewModel) {
        self.viewModel = viewModel
    }
    
    @IBAction func articleWebsiteButton(_ sender: Any) {        
        // On ouvre le navigateur
        guard let url = viewModel.getURL() else {
            // On affiche une alerte
            let alert = UIAlertController(title: "Erreur", message: "Une erreur est survenue pour l'ouverture du navigateur avec le lien suivant: \(viewModel.sourceURL).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        // On ouvre le navigateur
        guard let url = viewModel.getURL() else {
            // On affiche une alerte
            let alert = UIAlertController(title: "Erreur", message: "Une erreur est survenue pour l'ouverture du navigateur avec le lien suivant: \(viewModel.sourceURL).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        let items = [viewModel.articleTitle, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Support de l'iPad. Il est nécessaire d'ajouter ces lignes car sinon ça crashe sur un iPad. Mais ça marche avec un iPhone.
        if let popover = activityViewController.popoverPresentationController, let sender = sender as? UIButton {
            popover.sourceView = sender
            popover.sourceRect = sender.frame
        }
            
        present(activityViewController, animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ArticleViewController {
    private func setBindings() {
        viewModel.$articleTitle
            .receive(on: DispatchQueue.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: articleTitleLabel)
            .store(in: &subscriptions)
        
        viewModel.$publishDate
            .receive(on: DispatchQueue.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: articlePublishDateLabel)
            .store(in: &subscriptions)
        
        viewModel.$author
            .receive(on: DispatchQueue.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: articleAuthorLabel)
            .store(in: &subscriptions)
        
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: articleContentLabel)
            .store(in: &subscriptions)
        
        viewModel.$articleSource
            .receive(on: DispatchQueue.main)
            .compactMap { String($0) }
            .assign(to: \.text, on: articleSourceLabel)
            .store(in: &subscriptions)
        
        // L'image va s'actualiser de façon réactive
        viewModel.$articleImage
            .receive(on: RunLoop.main)
            .compactMap{ URL(string: $0) }
            .sink { [weak self] url in
                guard let vm = self?.viewModel, !vm.articleImage.isEmpty, let imageURL = URL(string: vm.articleImage) else {
                    // print("-> ERREUR: URL de l'image indisponible")
                    self?.articleImageView.image = UIImage(named: "ArticleImageNotAvailable")
                    return
                }
                
                // Avec Kingfisher, c'est asynchrone, rapide et efficace. Le cache est géré automatiquement.
                let defaultImage = UIImage(named: "ArticleImageNotAvailable")
                let resource = ImageResource(downloadURL: imageURL)
                self?.articleImageView.kf.indicatorType = .activity // Indicateur pendant le téléchargement
                self?.articleImageView.kf.setImage(with: resource, placeholder: defaultImage)
        }.store(in: &subscriptions)
    }
}
