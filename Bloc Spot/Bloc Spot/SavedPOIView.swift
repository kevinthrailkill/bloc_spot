//
//  SavedPOIView.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/23/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit


protocol POIDetailProtocol : NSObjectProtocol {
    func loadNewScreen(controller: UIViewController);
}

class SavedPOIView: UIView {
    
    
    weak var delegate: POIDetailProtocol?

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var phoneText: UITextView!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var visited: UIButton!
    @IBAction func clickVisited(sender: UIButton) {
    }
    
    @IBAction func getDirections(sender: UIButton) {
        
        let placemark = MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: Double.init(poi!.latitude!), longitude: Double.init(poi!.longitude!)), addressDictionary: nil)
        let mapItem = MKMapItem.init(placemark: placemark)
        mapItem.name = poi!.name
        mapItem.phoneNumber = poi!.phone
        
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    
    @IBAction func sharePOI(sender: UIButton) {
        
        var itemsToShare = [String]()
        itemsToShare.append(title.text!)
        itemsToShare.append(distance.text!)
        itemsToShare.append(phoneText.text)
        itemsToShare.append(note.text)
        
        let actController = UIActivityViewController.init(activityItems: itemsToShare, applicationActivities: nil)
        
        
        self.delegate?.loadNewScreen(actController)
        
    }
    
    @IBAction func deletePOI(sender: UIButton) {
        DataController.sharedInstance.deletePOI(poi!)
    }
    
    var poi: POI?
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    

}


