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
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    /***** Foursquare Calls *****/
     
    func searchFourSquare(ll: String, pin: Pin, completionHandler: (success: Bool, array: [[String: AnyObject]]?, error:NSError?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            FoursquareClient.JSONKeys.latLog: ll,
            FoursquareClient.JSONKeys.clientID: FoursquareClient.Constants.clientID,
            FoursquareClient.JSONKeys.secret: FoursquareClient.Constants.secret,
            FoursquareClient.JSONKeys.version: FoursquareClient.Constants.fsVersion
        ]
        
        let task = taskForFourSquareGetMethod(FoursquareClient.Methods.search, paramters: parameters) {
            JSONResults, error in
            if let error = error {
                print("Something bad happend")
                completionHandler(success: false, array: nil, error: error)
                //Foursquare return what we need in a dictionary -> Dictionary -> Array
                // The array contain the location we want
            } else {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(JSONResults! as! NSData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let jsonResults = jsonData[FoursquareClient.returnKeys.response] as? NSDictionary {
                        if let venues = jsonResults[FoursquareClient.returnKeys.venues] as? NSArray {
                            //Each element in this array is a new venue and we will save it as a location
                            var i = 0
                            for venueDictionary in venues {
                                let name = venueDictionary.valueForKey(returnKeys.name) as? String
                                //The lat and Long are inside a dictionary called location we are going to need to go down another layer to get them
                                let location = venueDictionary.valueForKey(returnKeys.location) as? NSDictionary
                                let latitude = location?.valueForKey(returnKeys.latitude) as? Double
                                let longitude = location?.valueForKey(returnKeys.longitude) as? Double
                                // Some places don't have a URL will need to handle that
                                var url = venueDictionary.valueForKey(returnKeys.url) as? String
                                if url == nil {
                                    url = ""
                                }
                                //Here now is inside a dictionary called HereNow.
                                let hereNow = venueDictionary.valueForKey(returnKeys.hereNow) as? NSDictionary
                                let count = hereNow?.valueForKey(returnKeys.count) as? Int
                                // Total Checkins are in a dictionary called Stats
                                let stats = venueDictionary.valueForKey(returnKeys.stats) as? NSDictionary
                                let checkinsCount = stats?.valueForKey(returnKeys.checkinsCount) as? Int
                                let foursquareID = venueDictionary.valueForKey(returnKeys.foursquareID) as? String
                                let newVenue = Location(name: name!, latitude: latitude!, longitude: longitude!, url: url!, hereNow: count!, totalCheckins: checkinsCount!, foursquareID: foursquareID!, pin: pin, context: self.sharedContext)
                                
                                dispatch_async(dispatch_get_main_queue(),{
                                    CoreDataStackManager.sharedInstance().saveContext()
                                    })
                                i += 1
                            }
                            print("\(i)")
                            completionHandler(success: true, array: venues as! [[String : AnyObject]], error: nil)
                        } else {
                            completionHandler(success: false, array: nil, error: nil)
                        }
                    } else {
                        completionHandler(success: false, array: nil, error: nil)
                    }
                } catch {
                    completionHandler(success: false, array: nil, error: nil)
                }
            }
        }
    }
    
    func taskForFourSquareGetMethod(method: String, paramters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let mutableParameters = paramters
        
        let urlString = FoursquareClient.Constants.baseURL + method + FoursquareClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: data, error: nil)
            }
        }
        task.resume()
        return task
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