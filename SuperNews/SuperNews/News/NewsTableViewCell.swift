//
//  NewsTableViewCell.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import Kingfisher

final class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleSourceLabel: UILabel!
    
    private var viewModel: NewsCellViewModel!
    
    // Injection de dépendance
    func configuration(with viewModel: NewsCellViewModel) {
        self.viewModel = viewModel
        setView()
    }
    
    func setView() {
        self.articleTitleLabel.text = viewModel.articleTitle
        self.articleSourceLabel.text = viewModel.articleSource
        self.articleImage.image = nil
        
        guard let imageURL = URL(string: viewModel.articleImage) else {
            // print("-> ERREUR: URL de l'image indisponible")
            self.articleImage.image = UIImage(named: "ArticleImageNotAvailable")
            return
        }
        
        // Avec Kingfisher, c'est asynchrone, rapide et efficace. Le cache est géré automatiquement.
        let defaultImage = UIImage(named: "ArticleImageNotAvailable")
        let resource = ImageResource(downloadURL: imageURL)
        articleImage.kf.indicatorType = .activity // Indicateur pendant le téléchargement
        articleImage.kf.setImage(with: resource, placeholder: defaultImage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset Thumbnail Image View
        articleImage.image = nil
    }
}
