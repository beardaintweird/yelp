//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    var businesses: [Business]!
    var filteredData: [Business]!
    var isMoreDataLoading = false
    var loadingMoreView:ProgressIndicator?

    @IBOutlet weak var tableView: UITableView!
    

   let search = UISearchBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("new run")
        
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        Business.searchWithTerm("Food", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredData = self.businesses
            self.tableView.reloadData()
        self.tableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })

        
        //add a search bar
        
        search.sizeToFit()
        navigationItem.titleView = search
        self.search.placeholder = "e.g. \"Food\", \"Restaurants\""
        
        //progress indicator
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, ProgressIndicator.defaultHeight)
        loadingMoreView = ProgressIndicator(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += ProgressIndicator.defaultHeight;
        tableView.contentInset = insets
        
//        tableView.separatorInset = UIEdgeInsetsZero
        
        tableView.reloadData()

        }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(search: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        
        if searchText.isEmpty {
            filteredData = businesses
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = businesses.filter({(dataItem: Business) -> Bool in
                // If dataItem matches the searchText, return true to include it
//                let nameForSearch = dataItem.name
                if dataItem.categories!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
          tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(search: UISearchBar) {
        search.resignFirstResponder()
    }


/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = filteredData[indexPath.row]
        
        return cell
    }
    
    // infinite scrolling
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // checks if data is loading to prevent continuous requests
        isMoreDataLoading = false
        
            if (!isMoreDataLoading) {
                isMoreDataLoading = true
                
                // Calculate the position of one screen length before the bottom of the results
                let scrollViewContentHeight = tableView.contentSize.height
                let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
                
                // When the user has scrolled past the threshold, start requesting
                if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                    isMoreDataLoading = true
                    
                    // Update position of loadingMoreView, and start loading indicator
                    let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, ProgressIndicator.defaultHeight)
                    loadingMoreView?.frame = frame
                    loadingMoreView!.startAnimating()
                    
                    // ... Code to load more results ...
                    loadMoreData()
                
            }
        }
    }

    
    func loadMoreData() {
        Business.searchWithTerm("Food", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredData = self.businesses
            self.tableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
        // update flag
        self.isMoreDataLoading = false
        
        // stop progress indicator
        self.loadingMoreView!.stopAnimating()
        
        self.tableView.reloadData()
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