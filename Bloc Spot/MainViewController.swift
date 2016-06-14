//
//  MainViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/11/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var spotTableView: UITableView!
    
    
    var resultSearchController:UISearchController? = nil
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "Category Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
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
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let name = record.valueForKey("name") as? String {
            cell.textLabel?.text = name
            
        }
        
        if let phone = record.valueForKey("phone") as? String {
            cell.detailTextLabel?.text = phone
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Spot", forIndexPath: indexPath)
        
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
                let cell = self.spotTableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
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



