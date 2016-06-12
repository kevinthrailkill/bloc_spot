//
//  SearchTableViewController.swift
//  Bloc Spot
//
//  Created by Kevin Thrailkill on 6/12/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    let searchController = UISearchController(searchResultsController: nil)

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search for spots here ..."
        tableView.tableHeaderView = searchController.searchBar

        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        searchController.searchBar.barTintColor = UIColor.groupTableViewBackgroundColor()
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal;

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        UIView.animateWithDuration(0.5, delay: 0.3, options: [], animations: {
            self.searchController.active = true

            self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            }, completion: nil)
        
        self.tableView.setContentOffset(CGPointMake(0, -20), animated: true)
        
        

        
//        UIView.animateWithDuration(0.2, animations: {
//            self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//            self.searchController.active = true
//        })
        
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    // Mark: - Search Controller / Search Bar
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        tableView.reloadData()
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        print("Search Bar Presented")
        searchController.searchBar.becomeFirstResponder()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("Cancel Button Pressed")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Spot", forIndexPath: indexPath)

        // Configure the cell...

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


