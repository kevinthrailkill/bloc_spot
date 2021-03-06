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

    @IBOutlet var annotationView: SavedPOIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPOI : POI?
   
    
    let dataController = DataController.sharedInstance
    
    var selectedPin:MKMapItem? = nil
    
    var droppedPins = [MKMapItem]()
    
    var resultSearchController:UISearchController? = nil

    var currentLocation : CLLocation?
    var catChange : Bool?
    
    var filterCategories: [Int]?
    
    
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
        
        self.fetchedResultsController.fetchRequest.predicate = nil
        
        filterCategories = [1,1,1,1,1,1]
        
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
           
            let oldAnnotations = mapView.annotations
            
            for annotation in oldAnnotations {
                if(selectedPin.placemark.coordinate.longitude == annotation.coordinate.longitude && selectedPin.placemark.coordinate.latitude == annotation.coordinate.latitude){
                    mapView.removeAnnotation(annotation)
                }
            }
            
            
            DataController.sharedInstance.saveMapItem(selectedPin)
        }
    }
    
    func fetchResultsInsert(poi: POI) {
        
        
        let annotation = SavedAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: Double.init(poi.latitude!), longitude: Double.init(poi.longitude!)), poi: poi)

        mapView.addAnnotation(annotation)
        
        if(catChange == true){
            catChange = false
            mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    func fetchResultsDelete(poi: POI) {
        
        let coordinate = CLLocationCoordinate2D.init(latitude: Double.init(poi.latitude!), longitude: Double.init(poi.longitude!))
        
        
        let oldAnnotations = mapView.annotations
        
        for annotation in oldAnnotations {
            if(coordinate.longitude == annotation.coordinate.longitude && coordinate.latitude == annotation.coordinate.latitude){
                mapView.removeAnnotation(annotation)
            }
        }
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
            
            
            
        } else if (segue.identifier == "Category Map") {
            // pass data to next view
            
            
            let buttonCell = sender?.superview as! SavedPOIView
            
            let catViewController = segue.destinationViewController as! CategoryViewController
            catViewController.delegate = self
            catViewController.selectedIndex = Category.None.rawValue
            catViewController.selectedIndex = buttonCell.poi?.category as? Int
            catViewController.isFilterView = false
            
            selectedPOI = buttonCell.poi!
            catChange = true
            
        } else if (segue.identifier == "Map Filter") {
            // pass data to next view
            
            
            
            let catViewController = segue.destinationViewController as! CategoryViewController
            catViewController.delegate = self
//            catViewController.selectedIndex = Category.None.rawValue
//            catViewController.selectedIndex = buttonCell.poi?.category as? Int
            catViewController.isFilterView = true
            catViewController.selectedIndexes = filterCategories
            
                        
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
            
            
            
            let tempAnnotation = annotation as? SavedAnnotation
            
            
            
            pinView?.pinTintColor = Category(rawValue: tempAnnotation?.poi.category as! Int)!.categoryColor()

            
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
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? SavedAnnotation {
            print("Your annotation title: \(annotation.poi.name!)");
            
            annotation.title = ""
            
            let detailView = view.detailCalloutAccessoryView as? SavedPOIView
            
            detailView!.title.text = annotation.poi.name!
            detailView!.note.text = annotation.poi.note!
            
            if let latitude = annotation.poi.latitude as? Double,
                let longitude = annotation.poi.longitude as? Double {
                let spotLoc = CLLocation.init(latitude: latitude, longitude: longitude)
                var distance = spotLoc.distanceFromLocation(DataController.sharedInstance.currentLocation!) * 0.000621371192
                
                
                distance = round(distance * 100)/100
                
                if(distance < 1.0){
                    detailView!.distance.text = "(< 1 mi.)"
                }else{
                    detailView!.distance.text = "(" + distance.description + " mi.)"
                }
            }
            detailView!.phoneText.text = annotation.poi.phone
            detailView!.poi = annotation.poi
            detailView!.delegate = self
            
            let catInt = detailView!.poi!.category as! Int
            
            detailView!.category.setTitle(Category(rawValue: catInt)?.categoryName(), forState: UIControlState.Normal)
            detailView!.category.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            detailView!.category.backgroundColor = Category(rawValue: catInt)?.categoryColor()
            
            let isVisited = detailView!.poi!.visited as! Bool
            
            if(isVisited == true){
                detailView!.visited.setBackgroundImage(UIImage(named: "Visited.png"), forState: UIControlState.Normal)
            }else{
                detailView!.visited.setBackgroundImage(UIImage(named: "not Visited.png"), forState: UIControlState.Normal)
            }
            
            detailView!.isV = isVisited
            
            
            
        }
    }
    
    func mapView( mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation as? SavedAnnotation {
            print("Your deselected annotation title: \(annotation.poi.name!)");
            
             annotation.title = "temp"
            
            let poi = annotation.poi
            
            poi.note = annotationView.note.text
            poi.visited = annotationView.isV
            
            DataController.sharedInstance.updatePOI(annotation.poi)
            
            
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
            fetchResultsInsert((anObject as? POI)!)
            break;
        case .Delete:
            fetchResultsDelete((anObject as? POI)!)
            break;
        case .Update:
            fetchResultsUpdated((anObject as? POI)!)
            break;
        case .Move:
            break;
        }
    }
    
}

extension MapViewController : POIDetailProtocol {
    func loadNewScreen(controller: UIViewController){
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension MapViewController: CategoryProtocol {
    func updateCategory(category: Category){
        print(category)
        
        selectedPOI?.category = category.rawValue

    }
    
    func filterCategory(categories: [Int]) {
       filterCategories = categories
        
        var searchString : String = ""
        
        for i in 0..<Category.count {
            if(categories[i] == 1){
                let temp = "category = " + String(i) + " || "
                searchString += temp
            }
        }
        
        let range = searchString.startIndex.advancedBy(0) ..< searchString.endIndex.advancedBy(-4)
        
        
                
        let resultPredicate = NSPredicate(format: searchString.substringWithRange(range))
         self.fetchedResultsController.fetchRequest.predicate = resultPredicate
        
        
        do {
            try self.fetchedResultsController.performFetch()
            self.configureAnnotation()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
}





