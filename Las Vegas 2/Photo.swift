//
//  Photo.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/8/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)

class Photo: NSManagedObject {
    
    @NSManaged var photoUrl: String
    @NSManaged var filePath: String?
    @NSManaged var location: Location
    
    var image: UIImage? {
        if let filePath = filePath {
            if filePath == "error" {
                return UIImage(named: "noImage.jpg")
            }
            
            let fileName = filePath.lastPathComponent
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0]
            let pathArray = [dirPath, fileName]
            let fileUrl = NSURL.fileURLWithPathComponents(pathArray)!
            
            return UIImage(contentsOfFile: fileUrl.path!)
        }
        return nil
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoUrl: String, location: Location, context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoUrl = photoUrl
        self.location = location
    }
}


/** Reference are here: https://forums.developer.apple.com/thread/13580 **/
extension String {
    
    var lastPathComponent: String {
        
        get {
            return (self as NSString).lastPathComponent
        }
    }
}