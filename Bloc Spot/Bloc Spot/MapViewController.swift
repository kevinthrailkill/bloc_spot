//
//  MapViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/11/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit


protocol HandleMapSearch {
    func dropPinZoomIn(mapItem:MKMapItem)
}


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
   
    
    let dataController = DataController.sharedInstance
    
    var selectedPin:MKMapItem? = nil
    
    var droppedPins = [MKMapItem]()
    
    var resultSearchController:UISearchController? = nil

    
    var currentLocation : CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.delegate = self;
        mapView.delegate = self
        
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! SearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for spots here ..."
        searchBar.barTintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.searchBarStyle = UISearchBarStyle.Minimal;
        navigationItem.titleView = resultSearchController?.searchBar

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        locationSearchTable.handleMapSearchDelegate = self
        
        self.resultSearchController?.loadViewIfNeeded()


        // Do any additional setup after loading the view.
    }
    
    
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            selectedPin.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    func savePOI(){
        if let selectedPin = selectedPin {
            DataController.sharedInstance.saveMapItem(selectedPin)
        }
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "MainControllerSegue"){
            
            
            
        }
        

        
    }
}



extension MapViewController : DataControllerProtocol {
    
    // Mark: - Data Controller Delegate
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center:   dataController.currentLocation!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        print("Updating location")
    }
    
}


extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(mapItem:MKMapItem){
        // cache the pin
        
        droppedPins.append(mapItem)
        
        // clear existing pins
        
        //need to remove when adding multiple pins
        //mapView.removeAnnotations(mapView.annotations)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapItem.placemark.coordinate
        annotation.title = mapItem.placemark.name
        if let city = mapItem.placemark.locality,
            let state = mapItem.placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(mapItem.placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        
        pinView?.leftCalloutAccessoryView = button
        pinView?.leftCalloutAccessoryView?.tag = 1
        
        let saveButton = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        saveButton.setBackgroundImage(UIImage(named: "save"), forState: .Normal)
        
        pinView?.rightCalloutAccessoryView = saveButton
        pinView?.rightCalloutAccessoryView?.tag = 2
        
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        for place in droppedPins {

            if(place.placemark.coordinate.latitude == view.annotation!.coordinate.latitude && place.placemark.coordinate.longitude == view.annotation!.coordinate.longitude){
                
                selectedPin = place

                
                if (control.tag == 1) {
                    print("Get Directions")
                    self.getDirections()
                }
                else if (control.tag == 2) {
                    print("Save POI")
                    self.savePOI()
                }
            }
        }
    }
    
    
    
}




