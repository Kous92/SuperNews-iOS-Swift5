//
//  NewsMapViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import MapKit
import CoreLocation

class NewsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var countries = [Country]()
    var selectedCountryName = ""
    var selectedCountryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        if countries.count == 0 {
            initializeCountryData()
        }
        // Si l'utilisateur a autorisé l'accès, alors sa position sera marquée d'un point bleu.
        // map.showsUserLocation = true
        placePins()
    }
    
    private func placePins() {
        for i in countries.indices {
            let annotation = MKPointAnnotation()
            // let annotation = CountryAnnotation(title: countries[i].countryName, subtitle: countries[i].capital, coordinate: CLLocationCoordinate2D(latitude: countries[i].lat, longitude: countries[i].lon), countryCode: countries[i].countryCode)
            annotation.coordinate = CLLocationCoordinate2D(latitude: countries[i].lat, longitude: countries[i].lon)
            annotation.title = countries[i].countryName
            annotation.subtitle = countries[i].countryCode
            map.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?

        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView, let countryCode = annotation.subtitle {
            annotationView.canShowCallout = true
            // annotationView.
            // annotationView.image = UIImage(named: "fr")
            
            switch countryCode {
            case "ae":
                annotationView.image = UIImage(named: "ae")!
            case "ar":
                annotationView.image = UIImage(named: "ar")!
            case "at":
                annotationView.image = UIImage(named: "at")!
            case "au":
                annotationView.image = UIImage(named: "au")!
            case "be":
                annotationView.image = UIImage(named: "be")!
            case "bg":
                annotationView.image = UIImage(named: "bg")!
            case "br":
                annotationView.image = UIImage(named: "br")!
            case "ca":
                annotationView.image = UIImage(named: "ca")!
            case "ch":
                annotationView.image = UIImage(named: "ch")!
            case "cn":
                annotationView.image = UIImage(named: "cn")!
            case "co":
                annotationView.image = UIImage(named: "co")!
            case "cu":
                annotationView.image = UIImage(named: "cu")!
            case "cz":
                annotationView.image = UIImage(named: "cz")!
            case "de":
                annotationView.image = UIImage(named: "de")!
            case "eg":
                annotationView.image = UIImage(named: "eg")!
            case "fr":
                annotationView.image = UIImage(named: "fr")!
            case "gb":
                annotationView.image = UIImage(named: "gb")!
            case "gr":
                annotationView.image = UIImage(named: "gr")!
            case "hk":
                annotationView.image = UIImage(named: "hk")!
            case "hu":
                annotationView.image = UIImage(named: "hu")!
            case "id":
                annotationView.image = UIImage(named: "id")!
            case "ie":
                annotationView.image = UIImage(named: "ie")!
            case "il":
                annotationView.image = UIImage(named: "il")!
            case "in":
                annotationView.image = UIImage(named: "in")!
            case "it":
                annotationView.image = UIImage(named: "it")!
            case "jp":
                annotationView.image = UIImage(named: "jp")!
            case "kr":
                annotationView.image = UIImage(named: "kr")!
            case "lt":
                annotationView.image = UIImage(named: "lt")!
            case "lv":
                annotationView.image = UIImage(named: "lv")!
            case "ma":
                annotationView.image = UIImage(named: "ma")!
            case "mx":
                annotationView.image = UIImage(named: "mx")!
            case "my":
                annotationView.image = UIImage(named: "my")!
            case "ng":
                annotationView.image = UIImage(named: "ng")!
            case "nl":
                annotationView.image = UIImage(named: "nl")!
            case "no":
                annotationView.image = UIImage(named: "no")!
            case "nz":
                annotationView.image = UIImage(named: "nz")!
            case "ph":
                annotationView.image = UIImage(named: "ph")!
            case "pl":
                annotationView.image = UIImage(named: "pl")!
            case "pt":
                annotationView.image = UIImage(named: "pt")!
            case "ro":
                annotationView.image = UIImage(named: "ro")!
            case "rs":
                annotationView.image = UIImage(named: "rs")!
            case "ru":
                annotationView.image = UIImage(named: "ru")!
            case "sa":
                annotationView.image = UIImage(named: "sa")!
            case "se":
                annotationView.image = UIImage(named: "se")!
            case "sg":
                annotationView.image = UIImage(named: "sg")!
            case "si":
                annotationView.image = UIImage(named: "si")!
            case "sk":
                annotationView.image = UIImage(named: "sk")!
            case "th":
                annotationView.image = UIImage(named: "th")!
            case "tr":
                annotationView.image = UIImage(named: "tr")!
            case "tw":
                annotationView.image = UIImage(named: "tw")!
            case "ua":
                annotationView.image = UIImage(named: "ua")!
            case "us":
                annotationView.image = UIImage(named: "us")!
            case "ve":
                annotationView.image = UIImage(named: "ve")!
            case "za":
                annotationView.image = UIImage(named: "za")!
            default:
                annotationView.image = UIImage(named: "fr")!
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let countryCode = view.annotation?.subtitle, let countryName = view.annotation?.title {
            print("OK pour \(countryCode!)")
            selectedCountryCode = countryCode!
            selectedCountryName = countryName!
            performSegue(withIdentifier: "countryNewsSegue", sender: self)
        }
        
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation sélectionnée: \(String(describing: view.annotation?.title!))")
    }
    
    // De la fenêtre de l'annotation, on transite vers le ViewController de l'article en transférant les données de la cellule
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? CountryNewsViewController {
            
            guard !selectedCountryName.isEmpty && !selectedCountryCode.isEmpty else {
                return
            }
            
            // On envoie au ViewController le code du pays pour cibler les articles en questions
            destination.countryCode = selectedCountryCode
            destination.countryName = selectedCountryName
        }
    }
    
    private func initializeCountryData() {
        // Vérification de l'existence du fichier data.json
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json") else {
            return
        }
        
        let url = URL(fileURLWithPath: path)
        var countryList: Countries?
        
        do {
            // Récupération des données JSON en type Data
            let data = try Data(contentsOf: url)
            
            // Décodage des données JSON en objets exploitables
            countryList = try JSONDecoder().decode(Countries.self, from: data)
            
            if let result = countryList {
                // print(result.countries)
                countries = result.countries
            } else {
                print("Échec lors du décodage des données")
            }
        } catch {
            print("ERREUR: \(error)")
        }
    }
}
