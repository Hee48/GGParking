//
//  CustomAnnotationViewController.swift
//  GGParking
//
//  Created by Hee  on 4/4/25.
//

import UIKit
import MapKit


class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var icon: String
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, icon: String) {
        self.coordinate = coordinate
        self.title = title
        self.icon = icon
    }
    
}
