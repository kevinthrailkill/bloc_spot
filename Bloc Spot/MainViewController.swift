//
//  MainViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/11/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MainViewController: UIViewController {

    @IBOutlet weak var spotTableView: UITableView!
    
    
    var resultSearchController:UISearchController? = nil
    
    var selectedPOI : POI?
    
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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Map Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backTapped))
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Category Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController?.searchResultsUpdater = self
        let searchBar = resultSearchController!.searchBar
        searchBar.placeholder = "Search for bookmarked spots here ..."
        searchBar.barTintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.searchBarStyle = UISearchBarStyle.Minimal;
        searchBar.sizeToFit()
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        spotTableView.tableHeaderView = resultSearchController?.searchBar
        
        self.resultSearchController?.loadViewIfNeeded()
        
        //Add to viewDidLoad:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        self.spotTableView.addGestureRecognizer(tapGesture)
        
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }


        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backTapped () {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    
    }
    
    func configureCell(cell: POITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let poi = fetchedResultsController.objectAtIndexPath(indexPath) as? POI
        
        // Update Cell
        
        cell.name?.text = poi?.name
        cell.phone?.text = poi?.phone
        cell.note?.text = poi?.note
        
        let spotLoc = CLLocation.init(latitude: (poi?.latitude as? Double)!, longitude: (poi?.longitude as? Double)!)
        var distance = spotLoc.distanceFromLocation(DataController.sharedInstance.currentLocation!) * 0.000621371192
        
        
        distance = round(distance * 100)/100
        
        if(distance < 1.0){
            cell.distance?.text = "(< 1 mi.)"
        }else{
            cell.distance?.text = "(" + distance.description + " mi.)"
        }
        
        cell.poi = poi
        cell.delegate = self
        cell.note.delegate = cell
        
        let catInt = poi?.category as! Int
        
        cell.category.setTitle(Category(rawValue: catInt)?.categoryName(), forState: UIControlState.Normal)
        cell.category.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cell.category.backgroundColor = Category(rawValue: catInt)?.categoryColor()
        
        
        
        let isVisited = poi?.visited as! Bool
        
        if(isVisited == true){
            cell.visited.setBackgroundImage(UIImage(named: "Visited.png"), forState: UIControlState.Normal)
        }else{
            cell.visited.setBackgroundImage(UIImage(named: "not Visited.png"), forState: UIControlState.Normal)
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    
    //Or since you wanted to dismiss when another cell is selected use:
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        dismissKeyboard()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "Category Main") {
            // pass data to next view
            
            
            let buttonCell = sender?.superview?!.superview as! POITableViewCell

            let catViewController = segue.destinationViewController as! CategoryViewController
            catViewController.delegate = self
            catViewController.selectedIndex = Category.None.rawValue
            catViewController.selectedIndex = buttonCell.poi?.category as? Int
            catViewController.isFilterView = false
            selectedPOI = buttonCell.poi!
            
        }
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Spot", forIndexPath: indexPath) as! POITableViewCell
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
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

extension MainViewController: NSFetchedResultsControllerDelegate  {
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.spotTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.spotTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                self.spotTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                self.spotTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = self.spotTableView.cellForRowAtIndexPath(indexPath) as! POITableViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                self.spotTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                self.spotTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
}

extension MainViewController : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        
        if(searchText?.characters.count > 0){
            
            let resultPredicate = NSPredicate(format: "name contains[c] %@", searchText!)
            
            fetchedResultsController.fetchRequest.predicate = resultPredicate
            
        }else{
            fetchedResultsController.fetchRequest.predicate = nil
        }
      
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        spotTableView.reloadData()
        
        
    }
    
}

extension MainViewController: POITableViewCellProtocol {
    func loadNewScreen(controller: UIViewController){
        self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension MainViewController: CategoryProtocol {
    func updateCategory(category: Category){
        print(category)
        
        selectedPOI?.category = category.rawValue
        
        DataController.sharedInstance.updatePOI(selectedPOI!)
        
        self.spotTableView.reloadData()
        
    }
    
    func filterCategory(categories: [Int]) {
        //leave blank
    }
}



