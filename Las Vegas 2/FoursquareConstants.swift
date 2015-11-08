//
//  FoursquareConstants.swift
//  Las Vegas 2
//
//  Created by Chris Archibald on 11/3/15.
//  Copyright © 2015 Chris Archibald. All rights reserved.
//

import Foundation

extension FoursquareClient {
    
    //These are constants that should never change
    struct Constants {
        static let baseURL = "https://api.foursquare.com/v2/venues/"
        static let clientID = "QLHZUN0VNMCUV0OMSJPTE0EBH3BQVMYLR41OUGQONTMWRLSJ"
        static let secret = "TXY4D3TTKCUOXVGZEXLRCRHOPBEMLS0FBGSP2SVN14O52ZB2"
        static let fsVersion = "20150906"
    }
    
    //These are API methods
    struct Methods {
        static let search = "search"
    }
    
    //These are JSONKeys
    struct JSONKeys {
        static let latLog = "ll"
        static let clientID = "client_id"
        static let secret = "client_secret"
        static let version = "v"
    }
    
    struct returnKeys {
        static let response = "response"
        static let venues = "venues"
        
        static let name = "name"
        static let latitude = "lat"
        static let longitude = "lng"
        static let url = "url"
        static let hereNow = "hereNow"
        static let count = "count"
        static let stats = "stats"
        static let checkinsCount = "checkinsCount"
        static let foursquareID = "id"
        static let location = "location"
        
        static let photos = "photos"
        static let items = "items"
        static let prefix = "prefix"
        static let suffix = "suffix"
    }
}
