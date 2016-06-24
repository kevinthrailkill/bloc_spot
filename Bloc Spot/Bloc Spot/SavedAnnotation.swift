//
//  SavedAnnotation.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/23/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit

class SavedAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var poi: POI
    
    init(coordinate: CLLocationCoordinate2D, poi: POI) {
        self.coordinate = coordinate
        self.poi = poi
        self.title = "Hello"
    }

}
