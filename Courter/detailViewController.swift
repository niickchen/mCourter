//
//  detailViewController.swift
//  Courter
//
//  Created by Jie Chen on 12/13/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

class detailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewObj: UITableView!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var editingbutton: UIButton!
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var owner: UILabel!
    
    @IBAction func doEdit(sender: AnyObject) {
        // chage the statuse of edit button while editing
        if self.tableViewObj.editing {
            editingbutton.setTitle("Edit", forState: UIControlState.Normal)
            self.tableViewObj.setEditing(false, animated: true)
        } else {
            editingbutton.setTitle("Done", forState: UIControlState.Normal)
            self.tableViewObj.setEditing(true, animated: true)
        }
    }
    
    var eventDetail: Event?
    
    var playersArray = [String]()
    var gameType = "TBB"
    var gameOwner: String?
    var currentUser = PFUser.currentUser()!.username
    var eventID: String?
    var userToDelete: PFObject?
    var canJoin: Bool?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding refreshControl to tableView as subView
        self.tableViewObj.addSubview(self.refreshControl)
        self.navigationItem.title = "Detail"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        
        type.text = eventDetail?.getEventTitle()
        startTime.text = eventDetail?.getStartTime()
        endTime.text = eventDetail?.getEndTime()
        owner.text = eventDetail?.getOwnerUsername()
        
        //print(currentUser)
        
        gameType = (eventDetail?.getEventTitle())!
        gameOwner = (eventDetail?.getOwnerUsername())!
        
        // Initializing players data
        let playersQuery = PFQuery(className: "Event")
        playersQuery.whereKey("owner", equalTo: gameOwner!)
        playersQuery.includeKey("Players")
        playersQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("\(error) \(error.userInfo)")
            } else if let objects = objects {
                let rawEvent = objects[0]
                let rawPlayersArray = rawEvent["Players"] as! [PFObject]
                self.eventID = rawEvent.objectId
                print("This is eventID after retrieving: \(self.eventID)")
                print("This is: \(rawPlayersArray)")
                for rawPlayer in rawPlayersArray {
                    self.playersArray.append(rawPlayer["username"] as! String)
                }
                self.viewWillAppear(true)
                //print(self.playersArray)
            }
            
            self.tableViewObj.reloadData()
            
        }
        
        // disable the join button when the current user is owner
        if(self.gameOwner == self.currentUser){
            self.joinButton.enabled = false
            self.joinButton.setTitle("", forState: UIControlState.Normal)
        }else{
            self.editingbutton.enabled = false
            self.editingbutton.setTitle("", forState: UIControlState.Normal)
        }
        
        checkJoinAvailable()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if checkPlayerNotInGame(self.currentUser!) {
            self.joinButton.setTitle("Join", forState: UIControlState.Normal)
        } else if (!(checkPlayerNotInGame(self.currentUser!)) && (self.gameOwner == self.currentUser)) {
            self.joinButton.setTitle("", forState: UIControlState.Normal)
        } else {
            self.joinButton.setTitle("UnJoin", forState: UIControlState.Normal)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reloadTable(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableViewObj.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print("This is self.playersArray in cellForRow: \(self.playersArray)")
        let cell = tableView.dequeueReusableCellWithIdentifier("mycell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = playersArray[indexPath.row]
        return cell
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // This is the Refresh
        
        playersArray = [String]()
        // retrive players data
        let playersQuery = PFQuery(className: "Event")
        playersQuery.whereKey("owner", equalTo: gameOwner!)
        playersQuery.includeKey("Players")
        playersQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("\(error) \(error.userInfo)")
            } else if let objects = objects {
                let rawEvent = objects[0]
                let rawPlayersArray = rawEvent["Players"] as! [PFObject]
                self.eventID = rawEvent.objectId
                for rawPlayer in rawPlayersArray {
                    self.playersArray.append(rawPlayer["username"] as! String)
                }
                
                print(self.playersArray)
            }
            self.tableViewObj.reloadData()
            refreshControl.endRefreshing()
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
    
    func checkPlayerNotInGame(currentuser: String)->Bool{
        if(playersArray.count > 0){
            for i in 0...(playersArray.count-1){
                if(currentUser == playersArray[i]){
                    return false
                }
                else {}
                print("Here is checking the current wheather in the array")
                print(playersArray)
            }
        }
        
        return true
    }
    
    @IBAction func joinBtn(sender: AnyObject) {
        if(gameOwner == currentUser){
            print("Owner can not join game again")
        }else{
            // if already in the array
            var check = checkPlayerNotInGame(currentUser!)
            print(check)
            print(playersArray.count)
            if(check == false){
                // remove
                
                print("should remove")
                ///* Retrieve Event then Remove current user from it.
                let usernameToDelete = currentUser
                let userQuery = PFUser.query()
                userQuery!.whereKey("username", equalTo: usernameToDelete!)
                userQuery!.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                    if let error = error {
                        print("\(error) \(error.userInfo)")
                    } else if let objects = objects {
                        print("Objects Successfully retrived in userQuery: \(objects)")
                        let userToDelete = objects[0]
                        self.userToDelete = userToDelete
                        
                        let eventToUpdateQuery = PFQuery(className: "Event")
                        print("This is eventID before using: \(self.eventID!)")
                        eventToUpdateQuery.getObjectInBackgroundWithId(self.eventID!) {(object: PFObject?, error: NSError?) -> Void in
                            if let error = error {
                                print("\(error) \(error.userInfo)")
                            } else if let object = object {
                                let eventToUpdate = object
                                
                                
                                // Configuring the avaliableToJoin of eventToUpdate, Could Add set avaliableToJoin of eventToUpdate to false if eventToUpdate uploaded failed.
                                if (self.gameType == "Single Game" && self.playersArray.count == 2) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else if (self.gameType == "Double Game" && self.playersArray.count == 4) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else if (self.gameType == "Free Practice" && self.playersArray.count == 6) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else {
                                }
                                
                                eventToUpdate.removeObject(self.userToDelete!, forKey: "Players")
                                eventToUpdate.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("Event Object Uploaded")
                                        self.addRelod()
                                        print("This self.playersArray after removing: \(self.playersArray)")
                                        self.viewWillAppear(true)
                                    } else {
                                        print("\(error) \(error?.userInfo)")
                                        // Could Add set avaliableToJoin of eventToUpdate to false if eventToUpdate uploaded failed.
                                    }
                                }
                            }
                        }
                    }
                }
                //*/
            }
                // not in the array
            else{
                // check players available
                if(gameType == "Single Game" && playersArray.count >= 2){
                    // error
                    checkJoinAvailable()
                    print("Can not add")
                    var alert = UIAlertView(title: "Invalid", message: "Upto the Maxium!", delegate: self,cancelButtonTitle: "OK")
                    alert.show()
                }else if(gameType == "Double Game" && playersArray.count >= 4){
                    // error
                    checkJoinAvailable()
                    var alert = UIAlertView(title: "Invalid", message: "Upto the Maxium!", delegate: self,cancelButtonTitle: "OK")
                    alert.show()
                }
                else if (gameType == "Free Practice" && playersArray.count >= 6){
                    // error
                    checkJoinAvailable()
                    var alert = UIAlertView(title: "Invalid", message: "Upto the Maxium!", delegate: self,cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    // join
                    
                    print("should add")
                    ///* Retrieve Event then add new current user
                    let usernameToAdd = currentUser
                    let userQuery = PFUser.query()
                    userQuery!.whereKey("username", equalTo: usernameToAdd!)
                    userQuery!.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                        if let error = error {
                            print("\(error) \(error.userInfo)")
                        } else if let objects = objects {
                            print("Objects Successfully retrived in userQuery: \(objects)")
                            let userToDelete = objects[0]
                            self.userToDelete = userToDelete
                            
                            let eventToUpdateQuery = PFQuery(className: "Event")
                            print("This is eventID before using: \(self.eventID!)")
                            eventToUpdateQuery.getObjectInBackgroundWithId(self.eventID!) {(object: PFObject?, error: NSError?) -> Void in
                                if let error = error {
                                    print("\(error) \(error.userInfo)")
                                } else if let object = object {
                                    let eventToUpdate = object
                                    
                                    // Configuring the avaliableToJoin of eventToUpdate, Could Add set avaliableToJoin of eventToUpdate to false if eventToUpdate uploaded failed.
                                    if (self.gameType == "Single Game" && self.playersArray.count == 1) {
                                        eventToUpdate["avaliableToJoin"] = false
                                    } else if (self.gameType == "Double Game" && self.playersArray.count == 3) {
                                        eventToUpdate["avaliableToJoin"] = false
                                    } else if (self.gameType == "Free Practice" && self.playersArray.count == 5) {
                                        eventToUpdate["avaliableToJoin"] = false
                                    } else {
                                    }
                                    
                                    eventToUpdate.addObject(self.userToDelete!, forKey: "Players")
                                    eventToUpdate.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                        if (success) {
                                            print("Event Object Uploaded")
                                            self.addRelod()
                                            print("This self.playersArray after adding: \(self.playersArray)")
                                            self.viewWillAppear(true)
                                        } else {
                                            print("\(error) \(error?.userInfo)")
                                            //Could Add set avaliableToJoin of eventToUpdate to false if eventToUpdate uploaded failed.
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //*/
                }
            }
        }
        
        
    }
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            //indexPath.row gets the index of the object in the events array?? Idk how it does it, but it does
            
            let usernameToDelete = playersArray[indexPath.row]
            // owner can not delete himself
            if(usernameToDelete == gameOwner){
                print("Owner can not delete youself")
                var alert = UIAlertView(title: "Invalid", message: "Owner can not delete youself!", delegate: self,cancelButtonTitle: "OK")
                alert.show()
            }else{
                print("this is usernameToDelete: \(usernameToDelete)")
                let userQuery = PFUser.query()
                userQuery!.whereKey("username", equalTo: usernameToDelete)
                userQuery!.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                    if let error = error {
                        print("\(error) \(error.userInfo)")
                    } else if let objects = objects {
                        print("Objects Successfully retrived in userQuery: \(objects)")
                        let userToDelete = objects[0]
                        self.userToDelete = userToDelete
                        
                        let eventToUpdateQuery = PFQuery(className: "Event")
                        print("This is eventID before using: \(self.eventID!)")
                        eventToUpdateQuery.getObjectInBackgroundWithId(self.eventID!) {(object: PFObject?, error: NSError?) -> Void in
                            if let error = error {
                                print("\(error) \(error.userInfo)")
                            } else if let object = object {
                                let eventToUpdate = object
                                
                                // Configuring the avaliableToJoin of eventToUpdate, Could Add set avaliableToJoin of eventToUpdate to false if eventToUpdate uploaded failed.
                                if (self.gameType == "Single Game" && self.playersArray.count == 2) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else if (self.gameType == "Double Game" && self.playersArray.count == 4) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else if (self.gameType == "Free Practice" && self.playersArray.count == 6) {
                                    eventToUpdate["avaliableToJoin"] = true
                                } else {
                                }
                                
                                eventToUpdate.removeObject(self.userToDelete!, forKey: "Players")
                                eventToUpdate.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("Event Object Uploaded")
                                        self.playersArray.removeAtIndex(indexPath.row)
                                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                        self.addRelod()
                                    } else {
                                        print("\(error) \(error?.userInfo)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (self.tableViewObj.editing) {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    
    
    
    func addRelod (){
        playersArray = [String]()
        // retrive players data
        let playersQuery = PFQuery(className: "Event")
        playersQuery.whereKey("owner", equalTo: gameOwner!)
        playersQuery.includeKey("Players")
        playersQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("\(error) \(error.userInfo)")
            } else if let objects = objects {
                let rawEvent = objects[0]
                let rawPlayersArray = rawEvent["Players"] as! [PFObject]
                self.eventID = rawEvent.objectId
                for rawPlayer in rawPlayersArray {
                    self.playersArray.append(rawPlayer["username"] as! String)
                }
                //print(self.playersArray)
                self.viewWillAppear(true)
            }
            self.tableViewObj.reloadData()
        }
    }
    
    func checkJoinAvailable(){
        // check the available slots for the event and change the status value in the parse
    }

}
