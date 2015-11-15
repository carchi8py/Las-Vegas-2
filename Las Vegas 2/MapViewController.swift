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
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    /***** Map View Methods *****/
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        
        let locationCount = locations.count
        var i = 0
        var index: Int = 0
        for i = 0; i < locationCount; i++ {
            if view.annotation?.coordinate.latitude == locations[i].latitude && view.annotation?.coordinate.longitude == locations[i].longitude {
                index = i
            }
        }
        let photos = fetchAllPhotos(locations[index])
        var photoOne = UIImage(named: "placeholder")
        var photoTwo = UIImage(named: "placeholder")
        var photoThree = UIImage(named: "placeholder")
        print("\(photos.count)")
        if photos.count > 0 {
            photoOne = photos[0].image
        }
        if photos.count > 1 {
            photoTwo = photos[1].image
        }
        if photos.count > 2 {
            photoThree = photos[2].image
        }
        
        let name = locations[index].name
        let url = locations[index].url
        let hereNow = locations[index].hereNow
        let totalCheckins = locations[index].totalCheckins
        let foursquareID = locations[index].foursquareID
        
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
