//
//  ViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    
    var timer: Timer?
    var currentTime: Date {
        return Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayDateLabel.text = ""
        dayTimeLabel.text = ""
        
        // La date et l'heure sont mis à jour en temps réel, la fonction est ciblée par le sélecteur.
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(HomeViewController.updateTimeLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimeLabel() {
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .medium
        formatter1.locale = Locale(identifier: "FR-fr")
        
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .full
        formatter2.locale = Locale(identifier: "FR-fr")
        
        dayDateLabel.text = formatter2.string(from: currentTime as Date).capitalized
        dayTimeLabel.text = formatter1.string(from: currentTime as Date)
    }
    
    // Lors que l'on quitte l'appli
    deinit {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
}

