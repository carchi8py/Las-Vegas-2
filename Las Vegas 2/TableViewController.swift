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
    
    /***** Table view Controler methods *****/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("foursquareCell", forIndexPath: indexPath)
        cell.textLabel?.text = "Hi"
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}