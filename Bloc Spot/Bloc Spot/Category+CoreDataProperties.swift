//
//  Category+CoreDataProperties.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/13/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var name: String?
    @NSManaged var color: String?
    @NSManaged var poi: POI?

}
