//
//  NewsMapViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import MapKit
import CoreLocation

class NewsMapViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var countries = [Country]()
    var filteredCountries = [Country]()
    var selectedCountryName = ""
    var selectedCountryCode = ""
    var searchContent = ""
    var locationManager: CLLocationManager?
    @IBOutlet weak var countrySearchBar: UITextField!
    @IBOutlet weak var countryAutoCompletionTableView: UITableView!
    @IBOutlet weak var autoCompletionView: CustomView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        countrySearchBar?.delegate = self
        countrySearchBar.attributedPlaceholder = NSAttributedString(string: "Pays", attributes: [.foregroundColor: UIColor(named: "Placeholder") ?? UIColor.label])
        countryAutoCompletionTableView?.delegate = self
        countryAutoCompletionTableView.dataSource = self
        countryAutoCompletionTableView.isHidden = true
        countryAutoCompletionTableView.layer.cornerRadius = 6
        autoCompletionView.isHidden = true
        
        if countries.count == 0 {
            initializeCountryData()
        }
        
        // Si l'utilisateur a autorisé l'accès, alors sa position sera marquée d'un point bleu.
        map.showsUserLocation = true
        initializePosition()
        placePins()
    }
    
    private func initializeCountryData() {
        let countryData = getLocalCountryData()
        
        if let data = countryData {
            countries = data
            // Ce tableau sera utile pour filtrer la recherche et permettre l'autocomplétion à la recherche d'un pays particulier
            filteredCountries = data
        }
    }
}

extension NewsMapViewController: MKMapViewDelegate {
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
            
            // En fonction du code du pays, le drapeau associé sera affiché sur la carte.
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
    
    // Au clic sur le "i" de la bulle du marqueur, les news locales associées seront affichées.
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
    
    // De la fenêtre de la bulle du marqueur, on transite vers le ViewController de l'article en transférant les données de la cellule
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
}

extension NewsMapViewController: CLLocationManagerDelegate {
    @IBAction func locateButton(_ sender: Any) {
        // On définit une région visible en mètres, on va définir à 10 km.
        let regionRadius: CLLocationDistance = 10000
        
        switch locationManager?.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = locationManager?.location else {
                return
            }
            
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            map.setRegion(coordinateRegion, animated: true)
        
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            return
        }
        
        let authorization = manager.authorizationStatus
        
        // Si l'accès au service de localisation est autorisé
        if authorization == .authorizedAlways || authorization == .authorizedWhenInUse {
            let x = Double(first.coordinate.longitude)
            let y = Double(first.coordinate.latitude)
            print(String(format: "Longitude (x) = %.7f", x))
            print(String(format: "Latitude (y) = %.7f", y))
            // getAddress(from: first)
        }
    }
    
    private func initializePosition() {
        var authorizedLocation = false
        
        // On définit la position par défaut sur Paris
        let initialLocation = CLLocation(latitude: 48.866667, longitude: 2.333333)
        
        // On définit une région visible en mètres, on va définir à 100 km.
        let regionRadius: CLLocationDistance = 1000000
        
        switch locationManager?.authorizationStatus {
        case .denied: // Option: Jamais
            print("Accès refusé au service de localisation.")
            
            // On affiche une alerte
            let alert = UIAlertController(title: "Erreur", message: "Vous avez refusé l'accès au service de localisation. Merci de l'autoriser en allant dans Réglages > Confidentialité > Service de localisation > GPSLocation.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            break
            
        case .restricted: // Restreint par le contrôle parental
            print("Accès restreint au service de localisation par le contrôle parental.")
            
            // On affiche une alerte
            let alert = UIAlertController(title: "Erreur", message: "L'accès au service de localisation est restreint par le contrôle parental.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            break
            
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            
        default:
            // L'accès au service de localisation est autorisé
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
            // La localisation sera ici mise à jour en temps réel grâce au signal GPS.
            locationManager?.startUpdatingLocation()
            authorizedLocation = true
        }
        
        if authorizedLocation {
            guard let location = locationManager?.location else {
                return
            }
            
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            map.setRegion(coordinateRegion, animated: true)
            locationManager?.stopUpdatingLocation()
        } else {
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            map.setRegion(coordinateRegion, animated: true)
        }
    }
}

extension NewsMapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = countryAutoCompletionTableView.dequeueReusableCell(withIdentifier: "autoCompletion") as? CountryAutoCompletionTableViewCell else {
            return UITableViewCell()
        }
        
        // print(filteredCountries[indexPath.row].countryCode)
        cell.configuration(country: filteredCountries[indexPath.row])
        
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        countryAutoCompletionTableView.reloadData()
        countryAutoCompletionTableView.isHidden = false
        autoCompletionView.isHidden = false
    }
    
    // À ajouter en sélectionnant depuis le storyboard l'événement "Editing changed". C'est ici que l'autocomplétion se fait.
    @IBAction func textFieldDidChange(_ sender: Any) {
        guard let search = countrySearchBar.text?.lowercased(), !search.isEmpty else {
            filteredCountries = countries
            countryAutoCompletionTableView.reloadData()
            
            return
        }
        
        filteredCountries = countries.filter({ country in
            country.countryName.lowercased().contains(search)
        })
        
        countryAutoCompletionTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(countrySearchBar.text!)
        countryAutoCompletionTableView.isHidden = true
        autoCompletionView.isHidden = true
        countrySearchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        
        guard let search = countrySearchBar.text, !search.isEmpty else {
            return false
        }
        
        // Centrer sur le pays en question
        if countries.contains(where: {search == $0.countryName}) {
            let target = countries[countries.firstIndex(where: {search == $0.countryName})!]
            // On définit une région visible en mètres, on va définir à 10 km.
            let regionRadius: CLLocationDistance = 10000
            let countryLocation = CLLocationCoordinate2D(latitude: target.lat, longitude: target.lon)
            let coordinateRegion = MKCoordinateRegion(center: countryLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            map.setRegion(coordinateRegion, animated: true)
        }
        
        print("\(search) non trouvé, impossible d'être centré là-dessus.")
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row.
        countryAutoCompletionTableView.deselectRow(at: indexPath, animated: false)
        countryAutoCompletionTableView.isHidden = true
        autoCompletionView.isHidden = true
        countrySearchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        let search = filteredCountries[indexPath.row].countryName
        countrySearchBar.text = search
        
        // Centrer sur le pays en question
        if filteredCountries.contains(where: {search == $0.countryName}) {
            let target = filteredCountries[indexPath.row]
            // On définit une région visible en mètres, on va définir à 10 km.
            let regionRadius: CLLocationDistance = 10000
            let countryLocation = CLLocationCoordinate2D(latitude: target.lat, longitude: target.lon)
            let coordinateRegion = MKCoordinateRegion(center: countryLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            map.setRegion(coordinateRegion, animated: true)
        }
    }
}


