//
//  ArticleViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 15/04/2021.
//

import UIKit
import SafariServices

class ArticleViewController: UIViewController {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleImageLabel: UIImageView!
    @IBOutlet weak var articlePublishDateLabel: UILabel!
    @IBOutlet weak var articleAuthorLabel: UILabel!
    @IBOutlet weak var articleContentLabel: UILabel!
    @IBOutlet weak var articleSourceLabel: UILabel!
    
    var article: Article?
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let publishDateTime = stringToDateFormat(date: article?.publishedAt)
        // On récupère les données transférées lors de la transition vers ce ViewController par le "segue" (transition)
        articleTitleLabel.text = article?.title ?? "Titre indisponible"
        articleImageLabel.image = image
        articlePublishDateLabel.text = publishDateTime ?? "Date indisponible"
        articleAuthorLabel.text = article?.author ?? "Auteur indisponible"
        articleContentLabel.text = article?.content ?? "Contenu de l'article indisponible"
        articleSourceLabel.text = article?.source?.name ?? "Source indisponible"
    }
    
    private func stringToDateFormat(date: String?) -> String?
    {
        if let publishDate = date
        {
            let formatter1 = DateFormatter()
            let formatter2 = DateFormatter()
            formatter1.locale = Locale(identifier: "en_US_POSIX")
            formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter2.locale = Locale(identifier: "en_US_POSIX")
            formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            if let date = formatter1.date(from: publishDate), let time = formatter2.date(from: publishDate) {
                formatter1.locale = Locale(identifier: "fr_FR")
                formatter2.locale = Locale(identifier: "fr_FR")
                formatter1.dateStyle = .short
                formatter2.timeStyle = .short

                formatter1.string(from: date)
                formatter2.string(from: time)
                
                return "Le " + formatter1.string(from: date) + " à " + formatter2.string(from: time)
            }
        }

        return nil
    }
    
    @IBAction func articleWebsiteButton(_ sender: Any) {
        guard let urlSite = article?.url else {
            print("-> ERREUR: URL de la source indisponible.")
            return
        }
        
        // On ouvre le navigateur
        guard let url = URL(string: urlSite) else {
            // On affiche une alerte
            let alert = UIAlertController(title: "Erreur", message: "Une erreur est survenue pour l'ouverture du navigateur avec le lien suivant: \(urlSite).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
