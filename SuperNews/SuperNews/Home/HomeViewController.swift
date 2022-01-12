//
//  ViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayDateLabel.text = ""
        dayTimeLabel.text = ""
        
        // La date et l'heure sont mis à jour en temps réel, la fonction est ciblée par le sélecteur.
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeViewController.updateTimeLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimeLabel() {        
        dayDateLabel.text = getTodayDate()
        dayTimeLabel.text = getTodayTime()
    }
    
    // Lors que l'on quitte l'appli
    deinit {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
}

