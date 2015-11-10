//
//  MapViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/9/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Pin from Vegas View Map
    var selectedPin: Pin!
    
    var locations = [Location]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make the view delgate the map
        self.mapView.delegate = self
        
        //Set Inital Location to Las Vegas. This won't be the file location though
        let initialLocation = CLLocation(latitude: 36.1096745, longitude: -115.1735591)
        centerMapOnLocation(initialLocation, radius: 3.2)
        
        locations = fetchAllLocations()
        
        //Add Locations to Map
        addAllLocationsToMap()
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
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    /***** Location Functions *****/
    func addAllLocationsToMap() {
        var averageLatitude = 0.0
        var averageLongitude = 0.0
        var totalLocations = 0.0
        for location in locations {
            var newPin = MKPointAnnotation()
            newPin.coordinate.latitude = location.latitude
            averageLatitude += location.latitude
            newPin.coordinate.longitude = location.longitude
            averageLongitude += location.longitude
            totalLocations += 1
            
            mapView.addAnnotation(newPin)
        }
        let averageLocation = CLLocation(latitude: averageLatitude/totalLocations, longitude: averageLongitude/totalLocations)
        centerMapOnLocation(averageLocation, radius: 0.75)
        
    }
    
    /***** Helper Functions *****/
    
    let regionRadius: CLLocationDistance = 1000
    //Create a bounding box for our map
    func centerMapOnLocation(location: CLLocation, radius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * radius, regionRadius * radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
