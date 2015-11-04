//
//  Location.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 10/22/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
import CoreData

@objc(Location)

class Location: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var url: String
    @NSManaged var hereNow: Int
    @NSManaged var totalCheckins: Int
    @NSManaged var foursquareID: String
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, latitude: Double, longitude: Double, url:String, hereNow: Int, totalCheckins: Int, foursquareID: String, pin: Pin, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.url = url
        self.hereNow = hereNow
        self.totalCheckins = totalCheckins
        self.foursquareID = foursquareID
        self.pin = pin
    }
    
}