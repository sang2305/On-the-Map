//
//  UrlPostingViewController.swift
//  OnTheMap
//
//  Created by Sangeetha on 10/1/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation
import MapKit
import UIKit


class UrlPostingViewController: UIViewController,MKMapViewDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
    var latitude : Float!
    var longitude : Float!
    var objectID : String! = ""
    var uniqueKey: String! = udacityClient.sharedInstance().ID
    var firstName: String! = udacityClient.sharedInstance().firstName
    var lastName : String! = udacityClient.sharedInstance().lastName
    var mediaURL : String! =  ""
    var mapString : String!
     var appDelegate:      AppDelegate!
    var annotationLocation : CLLocationCoordinate2D!
    var finalUrlString :String!
    var check : Int!

    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var browseButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        urlTextField.delegate = self
        mapView.userInteractionEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        addMapActivityIndicator()
        getLatAndLonFromString(mapString)
    }
    
    func addMapActivityIndicator(){
        mapActivityIndicator.startAnimating()
        mapActivityIndicator.hidden = false
        
    }
    
    
    func removeMapActivityIndicator(){
        mapActivityIndicator.stopAnimating()
        mapActivityIndicator.hidden = true
        
    }
    
    func getLatAndLonFromString(location : String){
        
        //Create geocoder.
        let geocoder = CLGeocoder()
        
        
        
        //Retrieve location from user input.
        geocoder.geocodeAddressString(location, inRegion: nil) {
            resultArray, error in
            
            if let error = error {
                self.removeMapActivityIndicator()
                var alertController = UIAlertController(title: "Could not geocode your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            } else {
                
                if let location = resultArray!.first as? CLPlacemark?{
                    //Send it to the URL posting view controller.
                    self.latitude = Float(location!.location!.coordinate.latitude)
                    self.longitude = Float(location!.location!.coordinate.longitude)
                    self.updateAnnotation(self.latitude,longitude: self.longitude)
                    self.centreMapOnLocation(self.annotationLocation)
                    self.removeMapActivityIndicator()

                }
                
            }
        }
        
    }

    
    func updateAnnotation(latitude: Float,longitude: Float){
        let locationlatitude = CLLocationDegrees(latitude)
        let locationlongitude = CLLocationDegrees(longitude)
        let name = "\(firstName) \(lastName)"
        let url = "\(mediaURL)"
        annotationLocation = CLLocationCoordinate2D(latitude: locationlatitude, longitude: locationlongitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationLocation
        annotation.title = name
        annotation.subtitle = url
        mapView.addAnnotation(annotation)
    }

    
    func centreMapOnLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.13, 0.13)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView!.canShowCallout = true
        }
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = button
        return pinView
    }
    

    @IBAction func submitURL(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == true{
        self.checkURL()
        check = 1
        }else{
            dispatch_async(dispatch_get_main_queue(), {
                let errorAlert = UIAlertController(title: "Internet Connection Lost", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            })
        }
    }
    
    func postStudentInfo(){
        mediaURL = urlTextField.text
        parseClient.sharedInstance().postLocation(uniqueKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL, locationString: mapString, locationLatitude: latitude, locationLongitude: longitude){ (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
            }
        }

    }
    
    func checkURL(){
        
        var urlString = urlTextField.text
        
        
        // Check if URL string is empty
        if urlString!.isEmpty {
            var alertController = UIAlertController(title: "Please enter a web address to share", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }

        // Remove Spaces
        urlString = urlString!.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        
        // Validate URL
        parseClient.validateUrl(urlString, completion: { (success, finalurlString, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (success)
                {
                    if self.check == 1{
                        self.postStudentInfo()
                    }else if self.check == 2{
                        var urlString = self.urlTextField.text
                        //Check if url includes "http", add it if not.
                        if urlString!.rangeOfString("http", options: .CaseInsensitiveSearch) == nil {
                            self.finalUrlString = "http://" + urlString!
                        }else{
                            self.finalUrlString = urlString
                        }
                        
                        let URLVC = self.storyboard!.instantiateViewControllerWithIdentifier("displayURL") as! displayURLViewController
                        URLVC.URL = self.finalUrlString
                        self.presentViewController(URLVC, animated: true, completion: nil)

                    }
                }
                else
                {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        var urlalertController = UIAlertController(title: "\(error)", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        urlalertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(urlalertController, animated: true, completion: nil)
                        return
                        
                    })
                    
                    
                }
            })
            
        })
      
        
    }

    @IBAction func browseURL(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == true{
        check = 2
        self.checkURL()
        }else{
            dispatch_async(dispatch_get_main_queue(), {
                let errorAlert = UIAlertController(title: "Internet Connection Lost", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            })

        }
   
    }

    
    
    @IBAction func goBack(sender: AnyObject) {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //To move out of text editing when return is pressed
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        return true
    }


    
}
