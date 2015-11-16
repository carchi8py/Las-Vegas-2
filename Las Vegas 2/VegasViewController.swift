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
    @IBOutlet weak var waitingOnData: UIActivityIndicatorView!
    
    //Default to Restore map location when app is reopened
    let defaults = NSUserDefaults()
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waitingOnData.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        //Check if we have network connection
        if !Reachability.isConnectedToNetwork() {
            self.showAlert("No Network Connection", message: "Unable to connect to Internet")
        }
        
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
    
    /***** Core Data functions *****/
    
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
    
    //Send the selected pin to the table and map views
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        
        //Grab are 2 Controllers in the Tab Bar so that we can send the pin to them
        let tableVC = tabBar.viewControllers?[0] as! TableViewController
        let mapVC = tabBar.viewControllers?[1] as! MapViewController
        
        // Find the pin that was selected
        let pinCount = pins.count
        var i = 0
        var index: Int = 0
        for i = 0; i < pinCount; i++ {
            if view.annotation?.coordinate.latitude == pins[i].latitude && view.annotation?.coordinate.longitude == pins[i].longitude {
                index = i
            }
        }
        
        let pin = pins[index]
        
        //Send the pin to the Map and Table views
        tableVC.selectedPin = pin
        mapVC.selectedPin = pin
        
        self.navigationController?.pushViewController(tabBar, animated: true)
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
        
        //Download Venues from foursquare
        downloadFromFourSquare(pinToBeAdded)
        
        //Save the pin in to core data so that it can be recreated in the app is quit
        CoreDataStackManager.sharedInstance().saveContext()
        
        var dropPin = MKPointAnnotation()
        dropPin.coordinate.latitude = pinToBeAdded.latitude
        dropPin.coordinate.longitude = pinToBeAdded.longitude
        mapView.addAnnotation(dropPin)
    }
    
    /***** Download functions *****/
    func downloadFromFourSquare(pin: Pin){
        // Check fi we are connect to the internet
        if !Reachability.isConnectedToNetwork() {
            self.showAlert("No Network Connection", message: "Unable to connect to Internet")
        }
        let ll = "\(pin.latitude),\(pin.longitude)"
        startWaiting()
        let app = UIApplication.sharedApplication()
        app.networkActivityIndicatorVisible = true
        FoursquareClient.sharedInstance().searchFourSquare(ll, pin: pin, completionHandler: {
            success, data, error in
            if success {
                self.stopWaiting()
            } else {
                //app.networkActivityIndicatorVisible = false
                self.stopWaiting()
                self.showAlert("Error", message: "Unable to connect to FourSquare")
            }
        })
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
            self.showAlert("Error", message: "Unable to get Saved Pins")
            results = nil
        }
        return results as! [Pin]
    }
    
    /***** Waiting On data function *****/
    func startWaiting() {
        self.waitingOnData.hidden = false
        self.waitingOnData.startAnimating()
    }
    
    func stopWaiting() {
        let app = UIApplication.sharedApplication()
        self.waitingOnData.stopAnimating()
        self.waitingOnData.hidden = true
        app.networkActivityIndicatorVisible = false
    }
    
    /***** Helper Functions *****/

    let regionRadius: CLLocationDistance = 1000
    //Create a bounding box for our map
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 3.2, regionRadius * 3.2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
