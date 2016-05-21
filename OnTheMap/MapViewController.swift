//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Sangeetha on 9/8/15.
//  Copyright (c) 2015 Sangeetha. All rights reserved.
//

import Foundation

import MapKit


class MapViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
   // var students :[Student]!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayMapView()
        addMapActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinImg: UIImage = UIImage(named: "pinicon")!
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        let pinButton = UIBarButtonItem(image: pinImg, style: UIBarButtonItemStyle.Plain, target: self, action: "pin")
        let rightButtons = [refreshButton, pinButton]
        self.navigationItem.rightBarButtonItems = rightButtons
        mapView.delegate = self
    }
    
    func displayMapView(){
        mapView.removeAnnotations(mapView.annotations)
        
        parseClient.sharedInstance().getLocation(){(success,errorString) in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    self.removeMapActivityIndicator()
                   // self.students = parseClient.sharedInstance().studentLocations
                    //for student in self.students{
                    for student in (parseClient.sharedInstance().studentLocations){
                        self.createAnnotationForEach(student)
                    }
                   
                    }
                )
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeMapActivityIndicator()
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
                
            }
        }
        
        
    }

    func addMapActivityIndicator(){
        mapActivityIndicator.startAnimating()
        mapActivityIndicator.hidden = false
        
    }
    
    
    func removeMapActivityIndicator(){
        mapActivityIndicator.stopAnimating()
        mapActivityIndicator.hidden = true
        
    }

    
    func createAnnotationForEach(student: Student){
        let latitude = CLLocationDegrees(student.latitude)
        let longitude = CLLocationDegrees(student.longitude)
        let name = "\(student.firstName) \(student.lastName)"
        let url = "\(student.mediaURL)"
        let annotationLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationLocation
        annotation.title = name
        annotation.subtitle = url
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
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
        displayMapView()
    }
    
}