//
//  LocailyAnnotation.swift
//  Locaily
//
//  Created by SWUCOMPUTER on 6/17/19.
//  Copyright © 2019 SWUCOMPUTER. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocailyAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var Locaily: LocailyData?
    
    init (title: String, latitude: Double, longitude: Double, Locaily: LocailyData, subtitle: Int) {
        self.title = title
        self.coordinate = CLLocationCoordinate2D()
        self.coordinate.latitude = latitude
        self.coordinate.longitude = longitude
        self.Locaily = Locaily
        self.subtitle = String(subtitle)
    }
}
