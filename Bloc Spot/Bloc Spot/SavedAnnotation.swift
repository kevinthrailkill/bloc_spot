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
    var category: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, category: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.category = category
        
    }

}
