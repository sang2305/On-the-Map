//
//  parseClient.swift
//  OnTheMap
//
//  Created by Sangeetha on 9/9/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation

class parseClient : NSObject{
    
    var parseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    var restAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    var session : NSURLSession = NSURLSession.sharedSession()

    
    var studentLocations : [Student] = []
    func getLocation(completionHandler: ((success:Bool, errorString: String?)-> Void)){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
       
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Connection lost")
            }else{
                var parsingError : NSError? = nil
                var parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)as! NSDictionary?
                
                
                if parsedResult != nil{
                    if let parsedResult = parsedResult {
                        var studentDict = parsedResult["results"] as! NSArray
                        self.studentLocations = []
                        for dict in studentDict {
                            if let student = self.studentLocationData(dict as! NSDictionary){
                                self.studentLocations.append(student)
                            }
                        }
                    }
                    
                    completionHandler(success: true, errorString: nil)
                    
                }else{
                    
                    completionHandler(success: false, errorString: "Could not retrieve data from server")
                }
            }
            
        }
        task.resume()
            
    }
    
    func studentLocationData(studentDict: NSDictionary)->Student? {
        let firstName = studentDict["firstName"] as! String
        let lastName = studentDict["lastName"] as! String
        let latitude = studentDict["latitude"] as! Float
        let longitude = studentDict["longitude"] as! Float
        let mapString = studentDict["mapString"] as! String
        let mediaURL = studentDict["mediaURL"] as! String
        let objectId = studentDict["objectId"] as! String
        let uniqueKey = studentDict["uniqueKey"] as! String
        let updatedAt = studentDict["updatedAt"] as! String
        let initDictionary = ["firstName":firstName,"lastName":lastName,"latitude": latitude,"longitude":longitude,"mapString":mapString,"mediaURL":mediaURL,"objectId":objectId,"uniqueKey": uniqueKey,"updatedAt":updatedAt]
        
        return Student(initDictionary : initDictionary as! [String:AnyObject])
        
    }
    
    func postLocation(uniqueKey: String, firstName: String, lastName: String, mediaURL: String, locationString: String, locationLatitude: Float, locationLongitude: Float, completionHandler: (success: Bool, errorString: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(locationString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(locationLatitude), \"longitude\": \(locationLongitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        print(request)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Connection lost")
            } else {
                var error: NSError?
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                if parsedResult["createdAt"] != nil {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "An unknown error occurred")
                }
            }
        }
        task.resume()

    }
    
    struct ValidationQueue {
        static var queue = NSOperationQueue()
    }
    
    class func validateUrl(urlString: String?, completion:(success: Bool, urlString: String? , error: NSString) -> Void)
    {
        // Description: This function will validate the format of a URL, re-format if necessary, then attempt to make a header request to verify the URL actually exists and responds.
        // Return Value: This function has no return value but uses a closure to send the response to the caller.
        
        var formattedUrlString : String?
        
        // Ignore Nils & Empty Strings
        if (urlString == nil || urlString == "")
        {
            completion(success: false, urlString: nil, error: "Url String was empty")
            return
        }
        
        // Ignore prefixes (including partials)
        let prefixes = ["http://www.", "https://www.", "www."]
        for prefix in prefixes
        {
            if ((prefix.rangeOfString(urlString!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)) != nil){
                completion(success: false, urlString: nil, error: "Url String was prefix only")
                return
            }
        }
        
        // Ignore URLs with spaces (NOTE - You should use the below method in the caller to remove spaces before attempting to validate a URL)
        
        let range = urlString!.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
        if let test = range {
            completion(success: false, urlString: nil, error: "Url String cannot contain whitespaces")
            return
        }
        
        // Check that URL already contains required 'http://' or 'https://', prepend if it does not
        formattedUrlString = urlString
        if (!formattedUrlString!.hasPrefix("http://") && !formattedUrlString!.hasPrefix("https://"))
        {
            formattedUrlString = "http://"+urlString!
        }
        
        // Check that an NSURL can actually be created with the formatted string
        if let validatedUrl = NSURL(string: formattedUrlString!)
        {
            // Test that URL actually exists by sending a URL request that returns only the header response
            let request = NSMutableURLRequest(URL: validatedUrl)
            request.HTTPMethod = "HEAD"
            ValidationQueue.queue.cancelAllOperations()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: ValidationQueue.queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                let url = request.URL!.absoluteString
                
                // URL failed - No Response
              if (error != nil)
                {
                    completion(success: false, urlString: url, error: "Invalid URL")
                    return 
                }
                
                
                // URL Responded - Check Status Code
                if let urlResponse = response as? NSHTTPURLResponse
                {
                    print(urlResponse.statusCode)
                    if ((urlResponse.statusCode >= 200 && urlResponse.statusCode < 400) || urlResponse.statusCode == 405)// 200-399 = Valid Responses, 405 = Valid Response (Weird Response on some valid URLs)
                    {
                        completion(success: true, urlString: url, error: "The url: \(url) is valid!")
                        return
                    }
                    else // Error
                    {
                         print(urlResponse.statusCode)
                        completion(success: false, urlString: url, error: " HTTP \(urlResponse.statusCode) error")
                        return
                    }
                }
               
            })
        }
    }

    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> parseClient {
        
        struct Singleton {
            static var sharedInstance = parseClient()
        }
        
        return Singleton.sharedInstance
    }
    

}

