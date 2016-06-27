//
//  POITableViewCell.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/14/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import MapKit


protocol POITableViewCellProtocol : NSObjectProtocol {
    func loadNewScreen(controller: UIViewController);
}

class POITableViewCell: UITableViewCell {

    
    weak var delegate: POITableViewCellProtocol?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var phone: UITextView!
    
    @IBOutlet weak var visited: UIButton!
    
    @IBAction func isVisited(sender: UIButton) {
        
        let isVisited = poi?.visited as! Bool
        
        if(isVisited == false){
            visited.setBackgroundImage(UIImage(named: "Visited.png"), forState: UIControlState.Normal)
            poi?.visited = true
        }else{
            visited.setBackgroundImage(UIImage(named: "not Visited.png"), forState: UIControlState.Normal)
            poi?.visited = false
        }
        
        DataController.sharedInstance.updatePOI(poi!)
        
        
    }
    
    @IBOutlet weak var category: UIButton!
    
    @IBAction func changeCategory(sender: UIButton) {
    }
    
    @IBAction func directions(sender: UIButton) {
        let placemark = MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: Double.init(poi!.latitude!), longitude: Double.init(poi!.longitude!)), addressDictionary: nil)
        let mapItem = MKMapItem.init(placemark: placemark)
        mapItem.name = poi!.name
        mapItem.phoneNumber = poi!.phone
        
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    @IBAction func share(sender: UIButton) {
        
        
        var itemsToShare = [String]()
        itemsToShare.append(name.text!)
        itemsToShare.append(distance.text!)
        itemsToShare.append(phone.text)
        itemsToShare.append(note.text)
        
        let actController = UIActivityViewController.init(activityItems: itemsToShare, applicationActivities: nil)
        
        
        self.delegate?.loadNewScreen(actController)
        
        
        
    }
    
    @IBAction func deletePOI(sender: UIButton) {
        
        DataController.sharedInstance.deletePOI(poi!)
        
    }
    
    var poi : POI?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension POITableViewCell : UITextViewDelegate {
    func textViewDidEndEditing(textView: UITextView) {
        poi?.note = note.text
        
        DataController.sharedInstance.updatePOI(poi!)
    }
}
