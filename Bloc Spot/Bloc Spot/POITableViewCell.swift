//
//  POITableViewCell.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/14/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit

class POITableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UITextView!
    @IBOutlet weak var sub: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
