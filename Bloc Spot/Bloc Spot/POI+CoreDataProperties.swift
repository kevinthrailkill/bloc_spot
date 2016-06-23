//
//  POI+CoreDataProperties.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/23/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension POI {

    @NSManaged var city: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var state: String?
    @NSManaged var visited: NSNumber?
    @NSManaged var category: String?

}
