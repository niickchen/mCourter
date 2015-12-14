//
//  ViewController.swift
//  Courter
//
//  Created by n3turn on 10/24/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import CVCalendar
import Parse

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // UI Connections
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Initializing Calendar Variables
    var shouldShowDaysOut = true
    var animationFinished = true
    
    // Initializing current day
    var _currentDate = NSDate()
    
    // Initializing local eventsArray
    var eventsArray = [Event]()
    
    // Initializing tableView refreshControl
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    // Initializing DateFormatter
    let dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up the NavigationBar
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]

        // Adding refreshControl to tableView as subView
        self.tableView.addSubview(self.refreshControl)
        
        // Configuring dateFormatter's style, Default timeStyle is .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")

        // Initializing Calendar with Current Date
        monthLabel.text = CVDate(date: self._currentDate).globalDescription
        

        // Initializing Data of Local eventsArray with Initializing Version fetchEvents()
        self.refreshControl.beginRefreshing()
        fetchEvents() {rawEventsArray in
            print("Start Fetch Events")
            
            // Check if rawEventsArray is nil
            if rawEventsArray != nil {
                print("rawEventsArray is not nil")
                
                // Set dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .ShortStyle
                self.dateFormatter.dateStyle = .NoStyle
                
                // Wrapping each rawEvent and Appending it to local eventsArray
                for rawEvent in rawEventsArray! {
                    let wrappedEvent = Event(startTime: self.dateFormatter.stringFromDate(rawEvent["startTime"] as! NSDate), endtime: self.dateFormatter.stringFromDate(rawEvent["endTime"] as! NSDate), eventTitle: rawEvent["eventTitle"] as! String, ownerUsername: rawEvent["owner"] as! String)
                    wrappedEvent.setAvaliableToJoin(rawEvent["avaliableToJoin"] as! Bool)
                    self.eventsArray.append(wrappedEvent)
                }
                
                // Set out dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .NoStyle
                self.dateFormatter.dateStyle = .ShortStyle

                // If Specific Day has not existed in Parse, and Doesnot get any rawEventsArray
            } else {
                print("rawEventsArray is nil")
                
                // Initilizing eventsArray to new
                self.eventsArray = [Event]()
            }

            print("End Fetch Events")
            
            // Fetching Ended, reloading table
            self.reloadTable()
            self.refreshControl.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Start run method to return number of rows")
        print("this is eventsArray: \(self.eventsArray)")
        return eventsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell
        
        cell.startTimeLabel.text = eventsArray[indexPath.row].getStartTime()
        
        cell.endTimeLabel.text = eventsArray[indexPath.row].getEndTime()
        
        cell.gameTitleLabel.text = eventsArray[indexPath.row].getEventTitle()
        
        cell.gameOwnerLabel.text = eventsArray[indexPath.row].getOwnerUsername()
        
        if eventsArray[indexPath.row].isAvaliableToJoin() {
            cell.fractionLabel.text = "O"
            cell.fractionLabel.textColor = UIColor.greenColor()
            cell.backgroundColor = UIColor(red: 150.0/255.0, green: 255.0/255.0, blue: 150.0/255.0, alpha: 0.1)
        } else {
            cell.fractionLabel.text = "C"
            cell.fractionLabel.textColor = UIColor.redColor()
            cell.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 0.1)
        }
        
        return cell
    }
    
    // Control if can edit or not, default cannot.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromPickupToAdding" {
            print("Now perform the segue fromPickupToAdding")
            let addingScene = segue.destinationViewController as! addingViewController
            addingScene._currentDate = self._currentDate
            addingScene._addingDoneDelegate = self
            
        
        } else {
            let descScene = segue.destinationViewController as! detailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let selectedEvent = eventsArray[indexPath.row]
                descScene.eventDetail = selectedEvent
            }
        }
    }
    
    /* Use to edit cell of the TableView
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
        }
    }
    */
    
    func reloadTable(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchEvents(completionHandler: ([PFObject]?) -> Void) {
        
        // Make dayQuery, className equals to "Day"
        let dayQuery = PFQuery(className: "Day")
        
        // Set "Date" Value to specific date, .ShortStyle
        dayQuery.whereKey("Date", equalTo: self.dateFormatter.stringFromDate(self._currentDate))
        print("Today's date: \(self.dateFormatter.stringFromDate(self._currentDate))")
        
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
                    completionHandler(nil)
                    
                // If specific day has existed in Parse
                } else {
                    print("successfully get day objects")
                    print("This is dayObjects: \(dayObjects)")
                    // rawDay is always the first item in dayObjects
                    let rawDay = dayObjects[0]
                    print("This is rawDay: \(rawDay)")
                    
                    // Get the rawEventsArray in rawDay's Events array
                    let rawEventsArray = rawDay.objectForKey("Events") as? [PFObject]
                    print("this is rawEventsArray: \(rawEventsArray)")
                    
                    // take rawEventsArray to the outside function's parameter
                    completionHandler(rawEventsArray)
                }
            }
            print("End Finding")
        }
    }
    
    // Prevent rotation
    override func shouldAutorotate() -> Bool {
        return false
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Initializing Data of Local eventsArray with Initializing Version fetchEvents()
        self.eventsArray = [Event]()
        fetchEvents() {rawEventsArray in
            print("Start Fetch Events")
            
            // Check if rawEventsArray is nil
            if rawEventsArray != nil {
                print("rawEventsArray is not nil")
                
                // Set dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .ShortStyle
                self.dateFormatter.dateStyle = .NoStyle
                
                // Wrapping each rawEvent and Appending it to local eventsArray
                for rawEvent in rawEventsArray! {
                    let wrappedEvent = Event(startTime: self.dateFormatter.stringFromDate(rawEvent["startTime"] as! NSDate), endtime: self.dateFormatter.stringFromDate(rawEvent["endTime"] as! NSDate), eventTitle: rawEvent["eventTitle"] as! String, ownerUsername: rawEvent["owner"] as! String)
                    wrappedEvent.setAvaliableToJoin(rawEvent["avaliableToJoin"] as! Bool)
                    self.eventsArray.append(wrappedEvent)
                }
                
                // Set out dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .NoStyle
                self.dateFormatter.dateStyle = .ShortStyle
                
            }
            print("End Fetch Events")
            
            // Fetching Ended, reloading table
            self.reloadTable()
            refreshControl.endRefreshing()
        }
    }
}

extension ViewController: addingDoneDelegate {
    
    func doReloadTable() {
        
        // Initializing Data of Local eventsArray with Initializing Version fetchEvents()
        self.refreshControl.beginRefreshing()
        self.eventsArray = [Event]()
        fetchEvents() {rawEventsArray in
            print("Start Fetch Events")
            
            // Check if rawEventsArray is nil
            if rawEventsArray != nil {
                print("rawEventsArray is not nil")
                
                // Set dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .ShortStyle
                self.dateFormatter.dateStyle = .NoStyle
                
                // Wrapping each rawEvent and Appending it to local eventsArray
                for rawEvent in rawEventsArray! {
                    let wrappedEvent = Event(startTime: self.dateFormatter.stringFromDate(rawEvent["startTime"] as! NSDate), endtime: self.dateFormatter.stringFromDate(rawEvent["endTime"] as! NSDate), eventTitle: rawEvent["eventTitle"] as! String, ownerUsername: rawEvent["owner"] as! String)
                    wrappedEvent.setAvaliableToJoin(rawEvent["avaliableToJoin"] as! Bool)
                    self.eventsArray.append(wrappedEvent)
                }
                
                // Set out dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .NoStyle
                self.dateFormatter.dateStyle = .ShortStyle
                
            }
            print("End Fetch Events")
            
            // Fetching Ended, reloading table
            self.reloadTable()
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension ViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    /*
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        let date = dayView.date
        print(date.day)
        //print("\(calendarView.presentedDate.commonDescription) is selected!")
    }
    */
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        self._currentDate = calendarView.presentedDate.convertedDate()!
        
        // Initializing Data of Local eventsArray with Initializing Version fetchEvents()
        self.refreshControl.beginRefreshing()
        self.eventsArray = [Event]()
        fetchEvents() {rawEventsArray in
            print("Start Fetch Events")
            
            // Check if rawEventsArray is nil
            if rawEventsArray != nil {
                print("rawEventsArray is not nil")
                
                // Set dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .ShortStyle
                self.dateFormatter.dateStyle = .NoStyle
                
                // Wrapping each rawEvent and Appending it to local eventsArray
                for rawEvent in rawEventsArray! {
                    let wrappedEvent = Event(startTime: self.dateFormatter.stringFromDate(rawEvent["startTime"] as! NSDate), endtime: self.dateFormatter.stringFromDate(rawEvent["endTime"] as! NSDate), eventTitle: rawEvent["eventTitle"] as! String, ownerUsername: rawEvent["owner"] as! String)
                    wrappedEvent.setAvaliableToJoin(rawEvent["avaliableToJoin"] as! Bool)
                    self.eventsArray.append(wrappedEvent)
                }
                
                // Set out dateFormatter's timeStyle
                self.dateFormatter.timeStyle = .NoStyle
                self.dateFormatter.dateStyle = .ShortStyle
                
            }
            print("rawEventsArray is nil")
            print("End Fetch Events")
            
            // Fetching Ended, reloading table
            self.reloadTable()
            self.refreshControl.endRefreshing()
        }
    }



    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    //dotMarker functions, probably implementing later.
    /*
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }
        
        return false
    }
    */

    /*
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        let day = dayView.date.day
        
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        let numberOfDots = Int(arc4random_uniform(3) + 1)
        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        default:
            return [color] // return 1 dot
        }
    }
    */
    //
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
}
// MARK: - CVCalendarViewAppearanceDelegate

extension ViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions For Buttons, using as your need.

extension ViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}
