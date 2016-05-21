//
//  udacityClient.swift
//  OnTheMap
//
//  Created by Sangeetha on 8/18/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation

class udacityClient : NSObject{
    
    var username : String! = ""
    var password : String! = ""
    var ID : String! = ""
    var firstName : String! = ""
    var lastName :String! = ""
    
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil

    
    var session : NSURLSession!
    
    override init(){
        super.init()
        session = NSURLSession.sharedSession()
    }
    
    func createASession(completionHandler: (success: Bool, errorString: String?) -> Void){
       let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Connection lost")
            }else{
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError : NSError? = nil
                var parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments))as! NSDictionary
                if let login = parsedResult["account"] as? NSDictionary{
                    self.ID = login["key"] as! String
                    self.getUserData()
        
                completionHandler(success: true, errorString: nil)
                }else{
                    if let errorMessage = parsedResult["error"] as? String{
                        completionHandler(success: false, errorString: errorMessage)
                    }
                }
        
        
            }
        }
        
        task.resume()
        
   
    }
    
    func getUserData(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(ID)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }else{
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError : NSError? = nil
                var parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments))as! NSDictionary
                if let userData = parsedResult["user"] as? NSDictionary{
                    self.firstName = userData["first_name"] as! String
                    self.lastName = userData["last_name"] as! String
                
                
                }
            }
        }
        task.resume()
        
    }
    
    func logoutASession(completionHandler: (success: Bool, errorString: String?) -> Void){
    
    let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
    request.HTTPMethod = "DELETE"
    var xsrfCookie: NSHTTPCookie? = nil
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
    if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
        request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
   
    let task = session.dataTaskWithRequest(request) { data, response, error in
        if error != nil {
        completionHandler(success: false, errorString: "Could not logout successfully")
        }else{
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var parsingError : NSError? = nil
            var parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments))as! NSDictionary
            if parsedResult["session"] != nil{
                completionHandler(success: true, errorString: nil)
            }else{
                completionHandler(success: false, errorString: "Could not logout successfully")
            }
            }
        }
    task.resume()
    }
   
    
    
    
    
    
    
    
    
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> udacityClient {
        
        struct Singleton {
            static var sharedInstance = udacityClient()
        }
        
        return Singleton.sharedInstance
    }

    
    
}