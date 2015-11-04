//
//  FoursquareClient.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/3/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation

class FoursquareClient: NSObject {
    
    var session: NSURLSession
    var sessionID: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
    }
    
    /*****  HELPER FUNCTIONS  *****/
    
    //Return a shared Instance of the Foursquare Class
    class func sharedInstance() -> FoursquareClient {
        struct Singleton {
            static var shardInstance = FoursquareClient()
        }
        return Singleton.shardInstance
    }
    
    //This function escapes special charaters in the paremeters we pass to a 
    //url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            //make sure that it is a string value
            let stringValue = "\(value)"
            
            //escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            //Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        let separator = "&"
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator(separator)
    }
}