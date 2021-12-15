//
//  NewsMapViewModel.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 12/12/2021.
//

import Foundation
import Combine
import CoreLocation

final class NewsMapViewModel {
    private var countries = [Country]()
    private var filteredCountries = [Country]()
    public private(set) var annotationsViewModels = [AnnotationViewModel]()
    private var cellViewModels = [CountryCellViewModel]()
    public private(set) var autocompletionViewModels = [CountryCellViewModel]()
    private var locationService = GPSLocationService()
    private var location: CLLocation?
    private var locatedCountryName: String?
    
    // Les sujets, ceux qui émettent et reçoivent des événements
    var updateResult = PassthroughSubject<Bool, Error>()
    var annotationUpdated = PassthroughSubject<Bool, LocalServiceError>()
    var userLocation = PassthroughSubject<CLLocation, GPSLocationError>()
    var reverseGeocoding = PassthroughSubject<((CLLocation, String), (CLLocation, String)), GPSLocationError>()
    @Published var searchQuery = ""
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setBindings()
    }
    
   func initCountries() {
        guard let data = getLocalCountryData() else {
            annotationUpdated.send(completion: .failure(.noCountries))
            return
        }
        
        countries = data
        countries.forEach { country in
            cellViewModels.append(CountryCellViewModel(with: country))
            annotationsViewModels.append(AnnotationViewModel(countryCode: country.countryCode, countryName: country.countryName, coordinates: CLLocationCoordinate2D(latitude: country.lat, longitude: country.lon)))
        }
        
        autocompletionViewModels = cellViewModels
        annotationUpdated.send(true)
    }
    
    private func setBindings() {
        $searchQuery
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.searchCountry()
            }.store(in: &subscriptions)
    }
}

extension NewsMapViewModel {
    private func searchCountry() {
        autocompletionViewModels.removeAll()
        filteredCountries.removeAll()
        
        guard !searchQuery.isEmpty else {
            autocompletionViewModels = cellViewModels
            updateResult.send(true)
            return
        }
        
        filteredCountries = countries.filter { country in
            country.countryName.lowercased().contains(searchQuery.lowercased())
        }
        
        filteredCountries.forEach { autocompletionViewModels.append(CountryCellViewModel(with: $0)) }
        updateResult.send(true)
    }
    
    func getUserLocation() {
        locationService.fetchLocation { [weak self] result in
            switch result {
            case .success(let location):
                self?.location = location
                self?.userLocation.send(location)
            case .failure(let error):
                self?.userLocation.send(completion: .failure(error))
            }
        }
    }
    
    func positionReverseGeocoding() {
        guard let position = location else {
            reverseGeocoding.send(completion: .failure(.reverseGeocodingFailed))
            return
        }
        
        locationService.reverseGeocoding(location: position) { [weak self] result in
            switch result {
            case .success(let address):
                self?.locatedCountryName = address
                print("Après géocodage inversé: " + address)
                self?.getClosestCountryFromPosition()
            case .failure(let error):
                self?.reverseGeocoding.send(completion: .failure(error))
            }
        }
    }
    
    private func getClosestCountryFromPosition() {
        guard let position = location, let name = locatedCountryName else {
            return
        }
        
        var suggestedCoordinates = CLLocation()
        
        if annotationsViewModels.contains(where: { $0.countryName == name }), let viewModel = annotationsViewModels.first(where: { $0.countryName == name }) {
            print("Pays déjà présent: \(name)")
            suggestedCoordinates = CLLocation(latitude: viewModel.coordinates.latitude, longitude: viewModel.coordinates.longitude)
            
            print("Actuel: \(position), suggéré: \(suggestedCoordinates)")
            reverseGeocoding.send(((position, name), (suggestedCoordinates, name)))
            return
        }
        
        // On exploite la localisation et on calcule la distance entre les 2 pays
        var closestDistance = Double.infinity
        var suggestedCountry = ""
        
        
        annotationsViewModels.forEach { country in
            let coordinates = CLLocation(latitude: country.coordinates.latitude, longitude: country.coordinates.longitude)
            let distance = coordinates.distance(from: position)
            // print(distance)
            
            if distance < closestDistance {
                closestDistance = distance
                suggestedCountry = country.countryName
                suggestedCoordinates = coordinates
                print("Pays le plus proche de \(name): \(country.countryName)")
            }
        }
        
        
        print("Pays à suggérer: \(suggestedCountry)")
        reverseGeocoding.send(((position, name), (suggestedCoordinates, suggestedCountry)))
    }
    
    func getActualLocation() -> CLLocation? {
        return location
    }
}
