//
//  profileTableViewController.swift
//  Courter
//
//  Created by Kai Li on 12/13/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

class profileTableViewController: UITableViewController {

    
    @IBAction func logOutPressed(sender: AnyObject) {
        print("perform log out")
        PFUser.logOut()
        print("user has benn logout")
        self.performSegueWithIdentifier("logOutSegue", sender: self)
        print("this is after performSeguetoLogin")
    }
    
    let section = ["Personal Info", "Private Info"]
    var items = [[], []]
    let sectitle = [["Name","Bio"],["Email","Phone", "NetId"]]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the NavigationBar
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let user = PFUser.currentUser()
        var fullName = String(user?.objectForKey("username"))
        fullName = fullName.substringWithRange(Range<String.Index>(start: fullName.startIndex.advancedBy(9), end: fullName.endIndex.advancedBy(-1)))
        var email = String(user?.objectForKey("email"))
        email = email.substringWithRange(Range<String.Index>(start: email.startIndex.advancedBy(9), end: email.endIndex.advancedBy(-1)))
        var phone = String(user?.objectForKey("phone"))
        phone = phone.substringWithRange(Range<String.Index>(start: phone.startIndex.advancedBy(9), end: phone.endIndex.advancedBy(-1)))
        var bio = String(user?.objectForKey("Bio"))
        bio = bio.substringWithRange(Range<String.Index>(start: bio.startIndex.advancedBy(9), end: bio.endIndex.advancedBy(-1)))
        var netID = String(user?.objectForKey("netID"))
        netID = netID.substringWithRange(Range<String.Index>(start: netID.startIndex.advancedBy(9), end: netID.endIndex.advancedBy(-1)))
        items = [[fullName,bio], [email,phone,netID]]

        
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return section.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        
        ///*
        let userNameImage = UIImage(named: "user168.png")
        //let genderImage = UIImage(named: "gender.png")
        let bioImage = UIImage(named: "bio.png")
        let emailImage = UIImage(named: "email.png")
        let phoneImage = UIImage(named: "phone.png")
        let idImage = UIImage(named: "id.png")
        
        if(indexPath.section==0){
            switch(indexPath.row){
            case 0:
                cell.imageView!.image = userNameImage
                break
            case 1:
                cell.imageView!.image = bioImage
                break
            default:
                cell.imageView!.image = bioImage
                break
            }
        }
        else {
            switch(indexPath.row){
            case 0:
                cell.imageView!.image = emailImage
                break
            case 1:
                cell.imageView!.image = phoneImage
                break
            default:
                cell.imageView!.image = idImage
                break
            }
        }
        cell.textLabel?.text = sectitle[indexPath.section][indexPath.row]
        cell.detailTextLabel!.text = items[indexPath.section][indexPath.row] as! String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "editProfile"){
            var selectedRow = self.tableView.indexPathForCell(sender as! UITableViewCell)
            var destinationVC:editProfileController = segue.destinationViewController as! editProfileController
            destinationVC.row = selectedRow!.row
            destinationVC.section = selectedRow!.section
        }
    }
    
    
    func loadList(notification: NSNotification){
        //Reload Data after update
        self.tableView.reloadData()
    }

}
