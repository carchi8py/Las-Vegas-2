//
//  Reachability.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/14/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation
public class Reachability {
    
    class func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "https://google.com/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        do {
            var data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    Status = true
                }
            }
        } catch {
            Status = false
        }
        return Status
    }
}