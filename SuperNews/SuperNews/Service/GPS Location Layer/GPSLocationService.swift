//
//  GPSLocationService.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 13/12/2021.
//

import Foundation
import CoreLocation

final class GPSLocationService: NSObject {
    private var geocoder: CLGeocoder = CLGeocoder()
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    private var availableLocationService = false
    var locationCompletion: ((Result<CLLocation, GPSLocationError>) -> Void)?
    var geocodingCompletion: ((Result<String, GPSLocationError>) -> Void)?
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            availableLocationService = true
        } else {
            print("Service de localisation indisponible")
            availableLocationService = false
            locationCompletion?(.failure(.serviceNotAvailable))
            locationCompletion = nil
        }
    }
    
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("L'accès au service de localisation est restreint par le contrôle parental.")
            locationCompletion?(.failure(.restricted))
            locationCompletion = nil
        case .denied:
            print("Vous avez refusé l'accès au service de localisation. Merci de l'autoriser en allant dans Réglages > Confidentialité > Service de localisation > SuperNews.")
            locationCompletion?(.failure(.denied))
            locationCompletion = nil
        case .authorizedAlways, .authorizedWhenInUse:
            print("OK: la permission est accordée")
            break
        @unknown default:
            break
        }
    }
}

extension GPSLocationService: CLLocationManagerDelegate {
    func fetchLocation(completion: @escaping (Result<CLLocation, GPSLocationError>) -> Void) {
        checkLocationServices()
        checkLocationPermission()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.locationCompletion = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let x = Double(location.coordinate.longitude)
        let y = Double(location.coordinate.latitude)
        print(String(format: "Longitude (x) = %.7f", x))
        print(String(format: "Latitude (y) = %.7f", y))
        
        locationCompletion?(.success(location))
        locationCompletion = nil
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func reverseGeocoding(location: CLLocation, completion: @escaping (Result<String, GPSLocationError>) -> Void) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "fr_FR")) { placemark, error in
            guard let place = placemark?.first, error == nil else {
                completion(.failure(.reverseGeocodingFailed))
                print(error?.localizedDescription ?? "Erreur")
                return
            }
            
            print(place)
            
            if let country = place.country {
                completion(.success(country))
            } else {
                completion(.failure(.reverseGeocodingFailed))
            }
        }
    }
}
