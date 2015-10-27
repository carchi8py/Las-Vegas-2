//
//  VegasViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 10/21/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VegasViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    //The Map View Object
    @IBOutlet weak var mapView: MKMapView!
    
    //Default to Restore map location when app is reopened
    let defaults = NSUserDefaults()
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Make the view delgate the map
        self.mapView.delegate = self
        
        //Fetch all Pins that we haev saved
        pins = fetchAllPins()
        
        //Add pins to Map
        addAllPinsToMap()

        //Set Inital Location to Las Vegas
        let initialLocation = CLLocation(latitude: 36.1096745, longitude: -115.1735591)
        centerMapOnLocation(initialLocation)
        
        //Add a Long Press Gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongTapMap:")
        longPress.delegate = self
        longPress.numberOfTapsRequired = 0
        longPress.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
        }()
    
    /***** Map View Methods *****/
    
    //create and animate a new Pin
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin1")
        newPin.animatesDrop = true
        return newPin
    }
    
    
    /***** Long Press Methods fo UIGestureRecognizerDelegate *****/
    
    //If the long tap gesture is fired, create a new pin in the location of the
    // Long tap, and store so we can retreive it later.
    func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if gestureRecognizer.state != .Ended {
            return
        }
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: touchMapCoordinate.latitude,
            Pin.Keys.Longitude: touchMapCoordinate.longitude
        ]
        
        let pinToBeAdded = Pin(dictionary: dictionary, context: self.sharedContext)
        
        self.pins.append(pinToBeAdded)
        
        //Save the pin in to core data so that it can be recreated in the app is quit
        CoreDataStackManager.sharedInstance().saveContext()
        
        var dropPin = MKPointAnnotation()
        dropPin.coordinate.latitude = pinToBeAdded.latitude
        dropPin.coordinate.longitude = pinToBeAdded.longitude
        mapView.addAnnotation(dropPin)
    }
    
    /***** Pin Functions *****/
    
    //Places all the existing pin on to the map
    func addAllPinsToMap() {
        for pin in pins {
            var newPin = MKPointAnnotation()
            newPin.coordinate.latitude = pin.latitude
            newPin.coordinate.longitude = pin.longitude
            mapView.addAnnotation(newPin)
        }
    }
    
    //Grabs all saved pins from Core Data
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch {
            //TODO: Added a real error handling here.
            print("Something bad happened")
            results = nil
        }
        return results as! [Pin]
    }
    
    /***** Helper Functions *****/

    let regionRadius: CLLocationDistance = 1000
    //Create a bounding box for our map
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 3.2, regionRadius * 3.2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
