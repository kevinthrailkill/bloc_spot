//
//  MapViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/11/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let dataController = DataController.sharedInstance
    var currentLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.delegate = self;
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

