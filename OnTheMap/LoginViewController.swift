//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sangeetha on 8/14/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var signupButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
   
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeLoginActivityIndicator()
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
    
    // Adding and removing activity indicator
    
    func addLoginActivityIndicator(){
        loginActivityIndicator.startAnimating()
        loginActivityIndicator.hidden = false
        loginButton.enabled = false
        signupButton.enabled = false
    }
    
    
    func removeLoginActivityIndicator(){
        loginActivityIndicator.stopAnimating()
        loginActivityIndicator.hidden = true
        loginButton.enabled = true
        signupButton.enabled = true
    }
    
    
    @IBAction func loginButtonTouchUp(sender: AnyObject) {
        self.getSessionID()
        if usernameTextField.text!.isEmpty {
           textfieldEmpty("email address")
        } else if passwordTextField.text!.isEmpty {
           textfieldEmpty("password")
        } else {
            self.getSessionID()
        }
    }
    
    func textfieldEmpty(emptyTextField: String){
        let alertController = UIAlertController(title: "Please enter \(emptyTextField)", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
        self.loginFailedAnimation()
    }
    
    func getSessionID(){
        self.addLoginActivityIndicator()
       udacityClient.sharedInstance().username = usernameTextField.text
       udacityClient.sharedInstance().password = passwordTextField.text
          udacityClient.sharedInstance().createASession(){(success,errorString) in
            if success{
                self.completeLogin()
            }else{
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeLoginActivityIndicator()
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
                self.loginFailedAnimation()

            }
        }
        
    }
    
    func completeLogin(){
        
        dispatch_async(dispatch_get_main_queue(), {
      self.removeLoginActivityIndicator()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
          self.presentViewController(controller, animated: true, completion: nil)
       })
        print("Login successful")
        
    }
   

    
    
    
    @IBAction func signUpButtonTouchUp(sender: AnyObject) {
        let urlString = "https://www.udacity.com/account/auth#!/signup"
        let url = NSURL(string: urlString)!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    func loginFailedAnimation() {
        dispatch_async(dispatch_get_main_queue()) {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - 10, self.view.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + 10, self.view.center.y))
            self.view.layer.addAnimation(animation, forKey: "position")
        }
    }
    
    
  
}

extension LoginViewController {
    
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
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

}
