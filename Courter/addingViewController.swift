//
//  addingViewController.swift
//  Courter
//
//  Created by n3turn on 10/24/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

protocol addingDoneDelegate {
    
    func doReloadTable()
    
}

class addingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismissingAddingScene(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addingDone(sender: AnyObject) {
        print("Start Adding")
        
        // Set dateFormatter.timeStyle to No style
        self.dateFormatter.timeStyle = .NoStyle
        
        let eventToAdd = PFObject(className: "Event")
        print("eventToadd has been created")
        
        eventToAdd["startTime"] = self.dataArray[1][kDateKey]
        eventToAdd["endTime"] = self.dataArray[2][kDateKey]
        eventToAdd["eventTitle"] = _gameType
        eventToAdd["owner"] = PFUser.currentUser()?.username
        eventToAdd["avaliableToJoin"] = true
        eventToAdd.addObject(PFUser.currentUser()!, forKey: "Players")
        
        // Make dayQuery, className equals to "Day"
        let dayQuery = PFQuery(className: "Day")
        
        // Set "Date" Value to specific date, .ShortStyle
        dayQuery.whereKey("Date", equalTo: self.dateFormatter.stringFromDate(self._currentDate!))
        print("Today's date: \(self.dateFormatter.stringFromDate(self._currentDate!))")
        
        // Included the Event objects' details in Events array
        dayQuery.includeKey("Events")
        
        // Find Object with Closure
        print("Start find Day Object on the Parse")
        dayQuery.findObjectsInBackgroundWithBlock {(dayObjects: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                print("A error is happened in Dayquery")
                
                // This will be replaced by shoing the error popup window
                print("\(error) \(error.userInfo)")
                
            } else if let dayObjects = dayObjects {
                
                // If specific day has not existed in Parse
                if dayObjects.count == 0 {
                    print("Hello, the day is not existed")
                    
                    // Create a new Day with _currentDate then add evetnToAdd to it
                    let dayToCreate = PFObject(className: "Day")
                    dayToCreate["Date"] = self.dateFormatter.stringFromDate(self._currentDate!)
                    dayToCreate.addObject(eventToAdd, forKey: "Events")
                    dayToCreate.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("dayToCreatevEvent Object Uploaded")
                            self._addingDoneDelegate?.doReloadTable()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            print("\(error) \(error?.userInfo)")
                        }
                    }
                    // If specific day has existed in Parse
                } else {
                    print("successfully get day objects")
                    print("This is dayObjects: \(dayObjects)")
                    
                    // rawDay is always the first item in dayObjects
                    let rawDay = dayObjects[0]
                    print("This is rawDay: \(rawDay)")
                    
                    // add eventToAdd to retrieved day
                    rawDay.addObject(eventToAdd, forKey: "Events")
                    rawDay.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("rawDay Object Uploaded")
                            self._addingDoneDelegate?.doReloadTable()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            print("\(error) \(error?.userInfo)")
                        }
                    }
                    
                }
            }
            print("End Finding")
        }

    }
    
    
    // Initializing local data
    var _checked = [true, false, false]
    var _hasSelectedIndex = 0
    var _gameType = "Single Game"
    var _currentDate: NSDate?
    var _addingDoneDelegate: addingDoneDelegate?
    
    // Initializing DateFormatter
    let dateFormatter = NSDateFormatter()

    
    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 1
    let kDateEndRow   = 2
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end
    
    var dataArray: [[String: AnyObject]] = []
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    
    @IBOutlet var pickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuring dateFormatter's style
        print("This is AddingScene's _currentDate: \(self._currentDate!)")
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")
        
        // setup our data source
        let gameTypeCell = [kTitleKey : "Game Type"]
        let startTimeCell = [kTitleKey : "Start Date", kDateKey : self._currentDate!]
        let endTimeCell = [kTitleKey : "End Date", kDateKey : self._currentDate!]
        dataArray = [gameTypeCell, startTimeCell, endTimeCell]
        
        // if the local changes while in the background, we need to be notified so we can update the date
        // format in the table view cells
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Locale
    
    /*! Responds to region format or locale changes.
    */
    func localeChanged(notif: NSNotification) {
        // the user changed the locale (region format) in Settings, so we are notified here to
        // update the date format in the table view cells
        //
        tableView.reloadData()
    }
    
    
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
    
    @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRowAtIndexPath(indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! NSDate, animated: false)
            }
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    func hasInlineDatePicker() -> Bool {
        // delete a exclametion sign after datePickerIndexPath
        return datePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
    
    @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
    
    @param indexPath The indexPath to check if it represents start/end date cell.
    */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            var numRows = dataArray.count
            return ++numRows;
        }
        
        return dataArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        /*
        if indexPath.row == 0 {
        // we decide here that first cell in the table is not selectable (it's just an indicator)
        cell?.selectionStyle = .None;
        }
        */
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            // we have either start or end date cells, populate their date field
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(itemData[kDateKey] as! NSDate)
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label
            //
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = self._gameType
        }
        
        return cell!
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = datePickerIndexPath?.row < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: datePickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    /*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
    
    @param indexPath The indexPath used to display the UIDatePicker.
    */
    /*
    func displayExternalDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
    
    // first update the date picker's date value according to our model
    let itemData: AnyObject = self.dataArray[indexPath.row]
    self.pickerView.setDate(itemData.valueForKey(kDateKey) as NSDate, animated: true)
    
    // the date picker might already be showing, so don't add it to our view
    if self.pickerView.superview == nil {
    var startFrame = self.pickerView.frame
    var endFrame = self.pickerView.frame
    
    // the start position is below the bottom of the visible frame
    startFrame.origin.y = CGRectGetHeight(self.view.frame)
    
    // the end position is slid up by the height of the view
    endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame)
    
    self.pickerView.frame = startFrame
    
    self.view.addSubview(self.pickerView)
    
    // animate the date picker into view
    UIView.animateWithDuration(kPickerAnimationDuration, animations: { self.pickerView.frame = endFrame }, completion: {(value: Bool) in
    // add the "Done" button to the nav bar
    //self.navigationItem.rightBarButtonItem = self.doneButton
    })
    }
    }
    */
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: - Actions
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
    
    @param sender The sender for this action: UIDatePicker.
    */
    
    
    @IBAction func dateAction(sender: UIDatePicker) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
        
        let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.stringFromDate(targetedDatePicker.date)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromAddingToGameType" {
            let gameTypeScene = segue.destinationViewController as! gameTypeDetailTableViewController
            
            // transferring dayCollection to addingScene
            
            gameTypeScene._gameTypeSelectedDelegate = self
            gameTypeScene.checked = self._checked
            gameTypeScene.hasSelectedIndex = self._hasSelectedIndex
            
        }
    }
    
}

extension addingViewController: gameTypeSelectedDelegate {
    
    func updateData(gameType: String?, checkedArray: [Bool]?, hasSelectedIndex: Int?) {
        self._gameType = gameType!
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        cell?.detailTextLabel?.text = self._gameType
        self._checked = checkedArray!
        self._hasSelectedIndex = hasSelectedIndex!
    }
    
}
