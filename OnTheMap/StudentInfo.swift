//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Sangeetha on 9/14/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation

struct Student {
    var objectId : String!
    var uniqueKey : String!
    var firstName : String!
    var lastName : String!
    var mapString : String!
    var mediaURL : String!
    var latitude : Float!
    var longitude : Float!
    var updatedAt : String!
    
    init(initDictionary: [String : AnyObject]){
        self.firstName = initDictionary["firstName"] as! String
        self.lastName = initDictionary["lastName"] as! String
        self.latitude = initDictionary["latitude"] as! Float
        self.longitude = initDictionary["longitude"] as! Float
        self.mapString = initDictionary["mapString"] as! String
        self.mediaURL = initDictionary["mediaURL"] as! String
        self.objectId = initDictionary["objectId"] as! String
        self.uniqueKey = initDictionary["uniqueKey"] as! String
        self.updatedAt = initDictionary["updatedAt"] as! String
               
    }
}
