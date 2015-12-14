//
//  gameTypeDetailTableViewController.swift
//  courter
//
//  Created by n3turn on 12/14/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit

protocol gameTypeSelectedDelegate {
    
    func updateData(gameType: String?, checkedArray: [Bool]?, hasSelectedIndex: Int?)
    
}

class gameTypeDetailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func dismissingGameTypeDetailScene(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    let _gameTypes = ["Single Game", "Double Game", "Free Practice"]
    var checked = [true, false, false]
    var hasSelectedIndex = 0
    var _gameTypeSelectedDelegate: gameTypeSelectedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _gameTypes.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Configure the cell...
        
        if checked[indexPath.row] == false {
            
            cell.textLabel?.text = _gameTypes[indexPath.row]
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] == true {
            
            cell.textLabel?.text = _gameTypes[indexPath.row]
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
            checked[indexPath.row] = true
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: hasSelectedIndex, inSection: 0)) {
                cell.accessoryType = .None
                checked[hasSelectedIndex] = false
                hasSelectedIndex = indexPath.row
            }
            self._gameTypeSelectedDelegate?.updateData(self._gameTypes[self.hasSelectedIndex], checkedArray: self.checked, hasSelectedIndex: self.hasSelectedIndex)
        }
    }
}
