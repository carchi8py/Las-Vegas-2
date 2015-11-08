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
        
        let task = taskWithParameters(FoursquareClient.Methods.search, paramters: parameters) {
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
                            for venueDictionary in venues {
                                let name = venueDictionary.valueForKey(returnKeys.name) as? String
                                //if Name is nil we don't want to use this location (this shouldn't happen)
                                if name == nil {
                                    continue
                                }
                                
                                let foursquareID = venueDictionary.valueForKey(returnKeys.foursquareID) as? String
                                //If there is no foursquareID we don't want to use this location (this shouldn't happen)
                                if foursquareID == nil {
                                    continue
                                }
                                
                                //The lat and Long are inside a dictionary called location we are going to need to go down another layer to get them
                                let location = venueDictionary.valueForKey(returnKeys.location) as? NSDictionary
                                //If there is no location for a foursquare venue we want to skip it.
                                if location == nil {
                                    continue
                                }
                                let latitude = location?.valueForKey(returnKeys.latitude) as? Double
                                //If there is no latitude we don't want to use this location
                                if latitude == nil {
                                    continue
                                }
                                let longitude = location?.valueForKey(returnKeys.longitude) as? Double
                                //if there is no logitude we don't want to use this location
                                if longitude == nil {
                                    continue
                                }
                                
                                // Some places don't have a URL will need to handle that
                                var url = venueDictionary.valueForKey(returnKeys.url) as? String
                                if url == nil {
                                    url = ""
                                }
                                
                                //Here now is inside a dictionary called HereNow.
                                let hereNow = venueDictionary.valueForKey(returnKeys.hereNow) as? NSDictionary
                                // If hereNow dosn't exist we want count to equal 0
                                var count = 0
                                if hereNow != nil {
                                    count = hereNow?.valueForKey(returnKeys.count) as! Int
                                }
                                
                                // Total Checkins are in a dictionary called Stats
                                let stats = venueDictionary.valueForKey(returnKeys.stats) as? NSDictionary
                                var checkinsCount = 0
                                if stats != nil {
                                        checkinsCount = stats?.valueForKey(returnKeys.checkinsCount) as! Int
                                }
                                
                                self.sharedContext.performBlockAndWait {
                                
                                    let newLocation = Location(name: name!, latitude: latitude!, longitude: longitude!, url: url!, hereNow: count, totalCheckins: checkinsCount, foursquareID: foursquareID!, pin: pin, context: self.sharedContext)
                                
                                    //Now that we have the Venue we need to save picture for it
                                    self.downloadPhotosFromFourSqaure(newLocation, completionHnadler: {
                                        success, error in
                                    
                                        dispatch_async(dispatch_get_main_queue(),{
                                            CoreDataStackManager.sharedInstance().saveContext()
                                        })
                                    })
                                }
                            }
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
    
    func downloadPhotosFromFourSqaure(location: Location, completionHnadler: (success: Bool, error: NSError?) -> Void)
    {
        let parameters: [String: AnyObject] = [
            FoursquareClient.JSONKeys.clientID: FoursquareClient.Constants.clientID,
            FoursquareClient.JSONKeys.secret: FoursquareClient.Constants.secret,
            FoursquareClient.JSONKeys.version: FoursquareClient.Constants.fsVersion
        ]
        
        let urlString = FoursquareClient.Constants.baseURL + location.foursquareID + "/photos" + FoursquareClient.escapedParameters(parameters)
        let task = taskWithOutParameters(urlString){
            results, error in
            
            if let error = error{
                print("Something bad happened")
                completionHnadler(success: false, error: error)
            } else {
                do {
                    let jsonResults = try NSJSONSerialization.JSONObjectWithData(results! as! NSData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let response = jsonResults.valueForKey(FoursquareClient.returnKeys.response) as? NSDictionary {
                        if let photos = response.valueForKey(FoursquareClient.returnKeys.photos) as? NSDictionary {
                            if let items = photos.valueForKey(FoursquareClient.returnKeys.items) as? NSArray {
                                for item in items {
                                    let prefix = item.valueForKey(FoursquareClient.returnKeys.prefix) as! String
                                    let suffix = item.valueForKey(FoursquareClient.returnKeys.suffix) as! String
                                    
                                    let photoUrl = prefix + "250x250" + suffix
                                    self.sharedContext.performBlock{
                                        let newPhoto = Photo(photoUrl: photoUrl, location: location, context: self.sharedContext)
                                        
                                        self.savePhotoToDisk(newPhoto, completionHandler: {
                                            success, error in
                                            
                                            dispatch_async(dispatch_get_main_queue(), {
                                                CoreDataStackManager.sharedInstance().saveContext()
                                            })
                                        })
                                        
                                    }
                                }
                                completionHnadler(success: true, error: nil)
                            } else {
                                completionHnadler(success: false, error: nil)
                            }
                        }
                    }
                } catch {
                    completionHnadler(success: false, error: nil)
                }
            }
        }
        
    }
    
    func savePhotoToDisk(photo: Photo, completionHandler: (success :Bool, error: NSError?) -> Void) {
        
        let photoUrl = photo.photoUrl
        let photoRequest = NSURLRequest(URL: NSURL(string: photoUrl)!)
        
        let task = session.dataTaskWithRequest(photoRequest) {
            data, resonse, error in
            
            if let error = error {
                print("Something bad happend")
                completionHandler(success: false, error: error)
            } else {
                if let photoToSave = data {
                    let fileName = photoUrl.lastPathComponent
                    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                    let pathArray = [dirPath, fileName]
                    let fileUrl = NSURL.fileURLWithPathComponents(pathArray)!
                    
                    NSFileManager.defaultManager().createFileAtPath(fileUrl.path!, contents: photoToSave, attributes: nil)
                    
                    self.sharedContext.performBlockAndWait {
                        photo.filePath = fileUrl.path!
                    }
                    completionHandler(success: true, error: nil)
                }
            }
        }
        task.resume()
    }
    
    func taskWithParameters(method: String, paramters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
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
    
    func taskWithOutParameters(urlString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
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