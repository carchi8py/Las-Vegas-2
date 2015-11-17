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
    func fetchAllPhotos(venue: Location) -> [Photo] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "location == %@", venue)
        
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
        
        let photos = fetchAllPhotos(venue)
        var photo: Photo
        if photos.count > 0 {
            photo = photos[0]
            if photo.image != nil {
                let photoSize = CGSize(width: 250, height: 250)
                cell.imageView?.sizeThatFits(photoSize)
                cell.imageView?.image = photo.image
            }
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }
        
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = "Here now \(venue.hereNow), Total Checkins \(venue.totalCheckins)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = fetchAllLocations().count
        if count == 0 {
            if !Reachability.isConnectedToNetwork() {
                showAlert("No Network Connection", message: "Unable to connect to Internet")
                //prevent network activity from starting up just return.
            }
        }
        return count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let venue = fetchAllLocations()[indexPath.row]
        let photos = fetchAllPhotos(venue)
        
        var photoOne = UIImage(named: "placeholder")
        var photoTwo = UIImage(named: "placeholder")
        var photoThree = UIImage(named: "placeholder")
        
        //Set Photos if we have them, if not we will show the placeholder image
        if photos.count > 0 {
            photoOne = photos[0].image
        }
        if photos.count > 1 {
            photoTwo = photos[1].image
        }
        if photos.count > 2 {
            photoThree = photos[2].image
        }
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        
        let name = venue.name
        let url = venue.url
        let hereNow = venue.hereNow
        let totalCheckins = venue.totalCheckins
        let foursquareID = venue.foursquareID
        
        viewController.name = name
        viewController.photoOne = photoOne
        viewController.photoTwo = photoTwo
        viewController.photoThree = photoThree
        viewController.url = url
        viewController.hereNow = hereNow
        viewController.totalCheckins = totalCheckins
        viewController.foursquareID = foursquareID
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}