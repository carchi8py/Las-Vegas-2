//
//  TableViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 10/26/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    //Pin from Vegas View Map
    var selectedPin: Pin!
    
    //Code Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    /***** Core Data Functions *****/
    //Grab all Locations that match the pin
    func fetchAllLocations() -> [Location] {
        
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.selectedPin)
        fetchRequest.sortDescriptors = []
        
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let tryError as NSError {
            error.memory = tryError
            results = nil
        }
        
        if error != nil {
            print("Unable to get saved data \(error.debugDescription)")
        }
        
        return results as! [Location]
    }
    
    // Grab all Foursquare Photos that match the pin
    func fetchAllPhotos() -> [Photo] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let tryError as NSError {
            error.memory = tryError
            results = nil
        }
        
        if error != nil {
            print("Unable to get saved data \(error.debugDescription)")
        }
        
        return results as![Photo]
    }
    
    /***** Table view Controler methods *****/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("foursquareCell", forIndexPath: indexPath)
        let venue = fetchAllLocations()[indexPath.row]
        
        let photo = fetchAllPhotos()[indexPath.row]
        
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = "Here now \(venue.hereNow), Total Checkins \(venue.totalCheckins)"
        
        if photo.image != nil {
            let photoSize = CGSize(width: 250, height: 250)
            cell.imageView?.sizeThatFits(photoSize)
            cell.imageView?.image = photo.image
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(fetchAllLocations().count)")
        return fetchAllLocations().count
    }
    
}