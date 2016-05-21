//
//  InformationPostingController.swift
//  OnTheMap
//
//  Created by Sangeetha on 9/9/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class InformationPostingController:UIViewController,UITextFieldDelegate,MKMapViewDelegate{
    
    var latitude : CLLocationDegrees!
    var longitude : CLLocationDegrees!
    
    var location : String!
    var student : Student!
    var firstName : String = udacityClient.sharedInstance().firstName
    var lastName : String = udacityClient.sharedInstance().lastName
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var findMapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        locationField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func findLocationOnMap(sender: AnyObject) {
        if locationField.text!.isEmpty {
            let alertController = UIAlertController(title: "Please enter your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } else {
            
            //Send it to the URL posting view controller.
            let nextVC = self.storyboard?.instantiateViewControllerWithIdentifier("urlPostVC") as! UrlPostingViewController
            nextVC.mapString = self.locationField.text

            self.presentViewController(nextVC, animated: true, completion: nil)
}

    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //To move out of text editing when return is pressed
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        locationField.resignFirstResponder()
        return true
    }


    
}
