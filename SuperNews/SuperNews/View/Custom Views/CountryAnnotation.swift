//
//  CountryAnnotation.swift
//  SuperNews
//
//  Created by Koussaïla Ben Mamar on 20/04/2021.
//

import Foundation
import MapKit

class CountryAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var countryCode: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, countryCode: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.countryCode = countryCode
        super.init()
    }
}

