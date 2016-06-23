//
//  MapViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/11/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit
import CoreData


protocol HandleMapSearch {
    func dropPinZoomIn(mapItem:MKMapItem)
}


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var annotationView: UIView!
    
   
    
    let dataController = DataController.sharedInstance
    
    var selectedPin:MKMapItem? = nil
    
    var droppedPins = [MKMapItem]()
    
    var resultSearchController:UISearchController? = nil

    var currentLocation : CLLocation?
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "POI")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        
        return fetchedResultsController
    }()
    
    func configureAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
        
        if let fetchedAnnotations = self.fetchedResultsController.fetchedObjects {
            for i in fetchedAnnotations {
                fetchResultsInsert(i as! POI)
            }
        }
        
        
        
    }
    
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
        searchBar.delegate = locationSearchTable

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        locationSearchTable.handleMapSearchDelegate = self
        
        self.resultSearchController?.loadViewIfNeeded()


        // Do any additional setup after loading the view.
        
        
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try self.fetchedResultsController.performFetch()
            self.configureAnnotation()
            
            
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
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
    
    func fetchResultsInsert(poi: POI) {
        
        let placemark = MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: Double.init(poi.latitude!), longitude: Double.init(poi.longitude!)), addressDictionary: nil)
        
        
        
        let mapItem = MKMapItem.init(placemark: placemark)
        mapItem.name = poi.name
        mapItem.phoneNumber = poi.phone
        
        droppedPins.append(mapItem)
        
        
        var sub : String?
        
        if let city = poi.city,
            let state = poi.state {
            sub = "\(city) \(state)"
        }
        
        
        let annotation = SavedAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: Double.init(poi.latitude!), longitude: Double.init(poi.longitude!)), title: poi.name!, subtitle: sub!, category: poi.category!)
        
        
        
        
        mapView.addAnnotation(annotation)
    }
    
    func fetchResultsDelete(poi: POI) {
       // mapView.removeAnnotation(annotation: MKAnnotation)
    }
    
    func fetchResultsUpdated(poi: POI) {
        fetchResultsDelete(poi)
        fetchResultsInsert(poi)
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
        
        
      //  mapView.showAnnotations(mapView.annotations, animated: true)
        
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
        } else if annotation is SavedAnnotation {
            
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            

            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true

            

            
            pinView?.pinTintColor = UIColor.redColor()

            
            let widthConstraint = NSLayoutConstraint(item: annotationView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 250)
            annotationView!.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: annotationView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            annotationView!.addConstraint(heightConstraint)

            pinView?.detailCalloutAccessoryView = annotationView

            
            return pinView
            
            
            
        } else{
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

extension MapViewController: NSFetchedResultsControllerDelegate  {
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
         UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            break;
        case .Delete:
            break;
        case .Update:
            break;
        case .Move:
            break;
        }
    }
    
}





