//
//  NewsMapViewController.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import UIKit
import MapKit
import CoreLocation
import Combine

class NewsMapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var countrySearchBar: UISearchBar!
    @IBOutlet weak var countryAutoCompletionTableView: UITableView!
    @IBOutlet weak var autoCompletionView: CustomView!
    @IBOutlet weak var locationButton: CustomButton!
    
    var viewModel = NewsMapViewModel()
    
    @Published private(set) var searchQuery = ""
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setSearchBar()
        setMapView()
        setBindings()
        viewModel.initCountries()
        viewModel.getUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countrySearchBar.changePlaceholderColor(.label)
        countrySearchBar.searchTextField.leftView?.tintColor = .label
    }
    
    private func setButton() {
        locationButton.isHidden = true
    }
    
    private func setMapView() {
        map.delegate = self
        map.showsUserLocation = true
    }
    
    private func setTableView() {
        countryAutoCompletionTableView?.delegate = self
        countryAutoCompletionTableView.dataSource = self
        countryAutoCompletionTableView.isHidden = true
        countryAutoCompletionTableView.layer.cornerRadius = 6
        autoCompletionView.isHidden = true
    }
    
    private func setSearchBar() {
        // Configuration barre de recherche
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Annuler"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .label
        countrySearchBar.backgroundImage = UIImage() // Supprimer le fond par défaut
        countrySearchBar.showsCancelButton = false
        countrySearchBar.delegate = self
    }
    
    private func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.countryAutoCompletionTableView.reloadData()
        }
    }
    
    private func setBindings() {
        func setSearchBinding() {
            $searchQuery
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { [weak self] value in
                    print(value)
                    self?.viewModel.searchQuery = value
                }.store(in: &subscriptions)
        }
        
        func setUpdateBinding() {
            viewModel.updateResult
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print("Erreur reçue: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] updated in
                    if updated {
                        self?.updateTableView()
                    }
                }.store(in: &subscriptions)
        }
        
        func setAnnotationBinding() {
            viewModel.annotationUpdated
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print("Erreur reçue: \(error.rawValue)")
                    }
                } receiveValue: { [weak self] updated in
                    print(updated)
                    if updated {
                        self?.placeAnnotations()
                    }
                }.store(in: &subscriptions)
        }
        
        func setLocationBinding() {
            viewModel.userLocation
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print(error.rawValue)
                        // On définit la position par défaut sur Paris
                        self?.centerMapToPosition(with: CLLocation(latitude: 48.866667, longitude: 2.333333), and: 1000000)
                    }
                } receiveValue: { [weak self] location in
                    print("Localisation réussie")
                    // Si l'utilisateur a autorisé l'accès, alors sa position sera marquée d'un point bleu.
                    self?.locationButton.isHidden = false
                    self?.viewModel.positionReverseGeocoding()
                }.store(in: &subscriptions)
        }
        
        func setGeocodingBinding() {
            viewModel.reverseGeocoding
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("OK: terminé")
                    case .failure(let error):
                        print(error.rawValue)
                    }
                } receiveValue: { [weak self] result in
                    print("Géocodage réussi")
                    // Si l'utilisateur a autorisé l'accès, alors sa position sera marquée d'un point bleu.
                    print(result)
                    self?.showSuggestedLocationAlert(with: (location: result.0.0, countryName: result.0.1), to: (location: result.1.0, countryName: result.1.1))
                }.store(in: &subscriptions)
        }
        
        setSearchBinding()
        setUpdateBinding()
        setAnnotationBinding()
        setLocationBinding()
        setGeocodingBinding()
    }
}

extension NewsMapViewController {
    
    private func showSuggestedLocationAlert(with actualLocation: (location: CLLocation, countryName: String), to suggestedLocation: (location: CLLocation, countryName: String)) {
        
        var message = ""
        
        if actualLocation.countryName == suggestedLocation.countryName {
            message = "Vous êtes localisé dans le même pays que celui est disponible sur la carte, ici: \(actualLocation.countryName). Voulez-vous centrer la carte sur la source du pays ? Sinon, la carte sera centrée sur votre position actuelle."
        } else {
            message = "Vous êtes localisé dans un pays (\(actualLocation.countryName)) qui n'est pas disponible sur la carte. Le pays le plus proche qui est suggéré est: \(suggestedLocation.countryName). Voulez-vous centrer la carte sur la source du pays suggéré ? Sinon, la carte sera centrée sur votre position actuelle."
        }
        
        let alert = UIAlertController(title: "Suggestion", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { [weak self] _ in
            self?.centerMapToPosition(with: suggestedLocation.location, and: 10000)
        }))
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: { [weak self] _ in
            self?.centerMapToPosition(with: actualLocation.location, and: 10000)
        }))
        self.present(alert, animated: true)
    }
    
    private func centerMapToPosition(with location: CLLocation, and radius: CLLocationDistance) {
        // On définit une région visible en mètres
        let regionRadius = radius
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
}

extension NewsMapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        countrySearchBar.setShowsCancelButton(true, animated: true) // Afficher le bouton d'annulation
        countryAutoCompletionTableView.reloadData()
        countryAutoCompletionTableView.isHidden = false
        autoCompletionView.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchQuery = ""
        countrySearchBar.text = ""
        countrySearchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        countryAutoCompletionTableView.isHidden = true
        autoCompletionView.isHidden = true
        countrySearchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        countrySearchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        countrySearchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
}

extension NewsMapViewController: MKMapViewDelegate {
    private func placeAnnotations() {
        viewModel.annotationsViewModels.forEach { annotationViewModel in
            let annotation = MKPointAnnotation()
            annotation.coordinate = annotationViewModel.coordinates
            annotation.title = annotationViewModel.countryName
            annotation.subtitle = annotationViewModel.countryCode
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
            // En fonction du code du pays, le drapeau associé sera affiché sur la carte.
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: countryCode ?? "fr")
        }
        
        return annotationView
    }
    
    // Au clic sur le "i" de la bulle du marqueur, les news locales associées seront affichées.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation, let countryCode = annotation.subtitle, let countryName = annotation.title {
            // De la fenêtre de la bulle du marqueur, on transite vers le ViewController de l'article en transférant les données de la cellule
            guard let countryNewsViewController = storyboard?.instantiateViewController(withIdentifier: "countryNewsViewController") as? CountryNewsViewController else {
                fatalError("Le ViewController n'est pas détecté dans le Storyboard.")
            }
            
            // Les propriétés subtitle et title sont des doubles optionnels de String, il faut unwrapper 2 fois.
            if let code = countryCode, let name = countryName {
                countryNewsViewController.configure(code: code, name: name)
                countryNewsViewController.modalPresentationStyle = .fullScreen
                present(countryNewsViewController, animated: true, completion: nil)
            }
        }
    }
}

extension NewsMapViewController: CLLocationManagerDelegate {
    @IBAction func locateButton(_ sender: Any) {
        
        guard let location = viewModel.getActualLocation() else {
            print("Impossible de centrer sur la position actuelle.")
            return
        }
        
        centerMapToPosition(with: location, and: 10000)
    }
}

extension NewsMapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.autocompletionViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "autoCompletion") as? CountryAutoCompletionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configuration(with: viewModel.autocompletionViewModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row.
        countryAutoCompletionTableView.deselectRow(at: indexPath, animated: false)
        countryAutoCompletionTableView.isHidden = true
        autoCompletionView.isHidden = true
        countrySearchBar.resignFirstResponder() // Le clavier disparaît (ce n'est pas automatique de base)
        let search = viewModel.autocompletionViewModels[indexPath.row].countryName
        countrySearchBar.text = search
        
        // Centrer sur le pays en question
        centerMapToPosition(with: viewModel.autocompletionViewModels[indexPath.row].coordinates, and: 10)
    }
}
