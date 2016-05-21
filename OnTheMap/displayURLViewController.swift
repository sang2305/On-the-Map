//
//  displayURLViewController.swift
//  OnTheMap
//
//  Created by Sangeetha on 10/4/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation
import UIKit

class displayURLViewController : UIViewController{
 
    var URL : String!
 
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestURL = NSURL(string:URL)
        print(URL)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
    
    @IBAction func goBack(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }

}