//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Sangeetha on 9/8/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation
import UIKit


class ListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
   
    @IBOutlet weak var tableActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var studentTableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayTableView()
        addTableActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTableView.delegate = self
        studentTableView.dataSource = self
        let pinImg: UIImage = UIImage(named: "pinicon")!
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        let pinButton = UIBarButtonItem(image: pinImg, style: UIBarButtonItemStyle.Plain, target: self, action: "pin")
        let rightButtons = [refreshButton, pinButton]
        self.navigationItem.rightBarButtonItems = rightButtons
    }
    
    func addTableActivityIndicator(){
        tableActivityIndicator.startAnimating()
        tableActivityIndicator.hidden = false
        
    }
    
    
    func removeTableActivityIndicator(){
        tableActivityIndicator.stopAnimating()
        tableActivityIndicator.hidden = true
        
    }


    
    func displayTableView(){
             parseClient.sharedInstance().getLocation(){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    self.removeTableActivityIndicator()
                    self.studentTableView.reloadData()
                    }
                )
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeTableActivityIndicator()
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
                
            }
        }
 
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (parseClient.sharedInstance().studentLocations).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! tableViewCell
        let student = (parseClient.sharedInstance().studentLocations)[indexPath.row]
        cell.studentName.text = "\(student.firstName) \(student.lastName)"
        cell.location.text = "\(student.mapString)"
        cell.urlLabel.text = "\(student.mediaURL)"
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = (parseClient.sharedInstance().studentLocations)[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
    }
    
    
    
    @IBAction func pinALocation(sender: AnyObject) {
        self.performSegueWithIdentifier("newPin", sender: nil)
    }
    

    @IBAction func logoutSession(sender: AnyObject) {
        udacityClient.sharedInstance().logoutASession(){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                )
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
                
            }
        }

    }
    
    func pin() {
        let infoPostingVC = self.storyboard!.instantiateViewControllerWithIdentifier("infoPostVC") as! InformationPostingController
        presentViewController(infoPostingVC, animated: true, completion: nil)
    }
    
    func refresh(){
        displayTableView()
    }

    
    
}