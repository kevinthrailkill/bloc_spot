//
//  CategoryViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/25/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit


protocol CategoryProtocol : NSObjectProtocol {
    func updateCategory(category: Category);
}

enum Category : Int {
    case Shopping
    case Food
    case Entertainment
    case Health
    case Travel
    case None
    
    
    
    
    static let categoryNames = [
        Shopping : "Shopping", Entertainment : "Entertainment", Food : "Food",
        Health : "Health", Travel : "Travel", None : "None"]
    
    static let categoryColors = [
        Shopping : UIColor(netHex: 0x1abc9c), Entertainment : UIColor(netHex: 0x2ecc71), Food : UIColor(netHex: 0x3498db),
        Health : UIColor(netHex: 0x9b59b6), Travel : UIColor(netHex: 0x34495e), None : UIColor(netHex: 0xc0392b)]
    
    func categoryName() -> String {
        if let cat = Category.categoryNames[self] {
            return cat
        }
        return "Error"
    }
    
    func categoryColor() -> UIColor {
        if let cat = Category.categoryColors[self] {
            return cat
        }
        return UIColor.blackColor()
    }
    
    
    
    static var count: Int { return Category.None.hashValue + 1}
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


class CategoryViewController: UIViewController {

    @IBOutlet weak var catTableView: UITableView!
    @IBOutlet weak var invisibleView: UIView!
    
    weak var delegate: CategoryProtocol?
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.handleTap(_:)))
        tap.delegate = self
        self.invisibleView.addGestureRecognizer(tap)
        
        
        let indexPath = NSIndexPath(forRow: selectedIndex!, inSection: 0)
        self.catTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        let cat = Category(rawValue: selectedIndex!)
        self.delegate?.updateCategory(cat!)
        self.dismissViewControllerAnimated(true, completion: nil)
        
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


extension CategoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
        
        
        
        
        
        if let catIndex = Category(rawValue: indexPath.row) {
            cell.textLabel!.text = catIndex.categoryName()
            cell.backgroundColor = catIndex.categoryColor()
        }
        
        
        if indexPath.row == selectedIndex {
            cell.accessoryType =  UITableViewCellAccessoryType.Checkmark
        }else{
            cell.accessoryType =  UITableViewCellAccessoryType.None
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Category"
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        
        tableView.reloadData()
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}

extension CategoryViewController : UIGestureRecognizerDelegate {
    
    
    
}

