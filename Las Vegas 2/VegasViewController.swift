//
//  VegasViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 10/21/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit

class VegasViewController: UIViewController, UIGestureRecognizerDelegate {

    //The Map View Object
    @IBOutlet weak var mapView: MKMapView!
    
    //Default to Restore map location when app is reopened
    let defaults = NSUserDefaults()
    
    var pins = [Pin]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
    
    /***** Helper Functions *****/

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 3.2, regionRadius * 3.2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

