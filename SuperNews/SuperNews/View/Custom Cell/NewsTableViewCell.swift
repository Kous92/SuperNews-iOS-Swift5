//
//  NewsTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleSourceLabel: UILabel!
    @IBOutlet weak var articleCellView: UIView!
    
    private var imageDataTask: URLSessionDataTask?
    let newsAPI = NewsAPIService.shared
    
    func configuration(with article: Article) {
        self.articleTitleLabel.text = article.title ?? "Titre indisponible."
        self.articleSourceLabel.text = article.source?.name ?? "Source indisponible."
        self.articleImage.image = nil
        
        guard let url = article.urlToImage, let imageURL = URL(string: url) else {
            print("-> ERREUR: URL de l'image indisponible")
            self.articleImage.image = UIImage(named: "ArticleImageNotAvailable")
            return
        }
        
        // Si l'url existe et que l'image n'est pas encore définie, on télécharge l'image de façon asynchrone
        newsAPI.downloadImage(with: imageURL) { [weak self] result -> (Void) in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData){
                    DispatchQueue.main.async {
                        self?.articleImage.image = image
                    }
                } else {
                    // Pas de données disponibles
                    DispatchQueue.main.async {
                        self?.articleImage.image = UIImage(named: "ArticleImageNotAvailable")
                    }
                }
            case .failure(_):
                // Pas de données disponibles
                DispatchQueue.main.async {
                    self?.articleImage.image = UIImage(named: "ArticleImageNotAvailable")
                }
            }
        }
        // loadImageWithCache(withURL: imageURL, session: newsAPI.imageSession)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset Thumnail Image View
        articleImage.image = nil
    }
}

extension UIImageView
{
    // Téléchargement asynchrone de l'image de l'article
    func loadImage(withUrl url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: url)
            {
                if let image = UIImage(data: imageData)
                {
                    DispatchQueue.main.async
                    {
                        self?.image = image
                    }
                } else {
                    // Pas d'image
                    self?.image = UIImage(named: "ArticleImageNotAvailable")
                }
            } else {
                // Pas d'image
                self?.image = UIImage(named: "ArticleImageNotAvailable")
            }
        }
    }
}
