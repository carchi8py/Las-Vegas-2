//
//  VegasViewController.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 10/21/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit

class VegasViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Set Inital Location to Las Vegas
        let initialLocation = CLLocation(latitude: 36.1096745, longitude: -115.1735591)
        centerMapOnLocation(initialLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /***** Helper Functions *****/

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 3.2, regionRadius * 3.2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

