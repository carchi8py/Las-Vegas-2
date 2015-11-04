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
    
    /***** Foursquare Calls *****/
     
    func searchFourSquare(ll: String, completionHandler: (success: Bool, array: [[String: AnyObject]]?, error:NSError?) -> Void) {
        
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
                        if let venues = jsonResults[FoursquareClient.returnKeys.venues] as? [[String:AnyObject]] {
                            completionHandler(success: true, array: venues, error: nil)
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