//
//  editProfileController.swift
//  Courter
//
//  Created by Kai Li on 12/13/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

class editProfileController: UIViewController {

    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var userInputTextField: UITextField!
    
    var row: Int = 0
    var section: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        var user = PFUser.currentUser()
        if(section == 0){
            switch(row){
            case 0:
                labelText.text = "Enter a new username for yourself"
                var fullName = String(user?.objectForKey("username"))
                fullName = fullName.substringWithRange(Range<String.Index>(start: fullName.startIndex.advancedBy(9), end: fullName.endIndex.advancedBy(-1)))
                userInputTextField.placeholder = fullName
                break
            case 1:
                labelText.text = "Change your Bio"
                var bio = String(user?.objectForKey("Bio"))
                bio = bio.substringWithRange(Range<String.Index>(start: bio.startIndex.advancedBy(9), end: bio.endIndex.advancedBy(-1)))
                userInputTextField.placeholder = bio
                break
            default:
                break
            }
        }
        else{
            switch(row){
            case 0:
                labelText.text = "Enter a new email"
                var email = String(user?.objectForKey("email"))
                email = email.substringWithRange(Range<String.Index>(start: email.startIndex.advancedBy(9), end: email.endIndex.advancedBy(-1)))
                userInputTextField.placeholder = email
                break
            case 1:
                labelText.text = "Enter a new phone number"
                var phone = String(user?.objectForKey("phone"))
                phone = phone.substringWithRange(Range<String.Index>(start: phone.startIndex.advancedBy(9), end: phone.endIndex.advancedBy(-1)))
                userInputTextField.placeholder = phone
                break
            case 2:
                labelText.text = "Enter a new NetID"
                var netID = String(user?.objectForKey("netID"))
                netID = netID.substringWithRange(Range<String.Index>(start: netID.startIndex.advancedBy(9), end: netID.endIndex.advancedBy(-1)))
                userInputTextField.placeholder = netID
                break
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func back(sender: UIBarButtonItem) {
        let user = PFUser.currentUser()
        if(!(userInputTextField.text!.isEmpty)){
            if(section == 0){
                switch(row){
                case 0:
                    user?.setObject(userInputTextField.text!, forKey: "username")
                    save()
                case 1:
                    user?.setObject(userInputTextField.text!, forKey: "Bio")
                    save()
                default:
                    break
                }
            }else{
                switch(row){
                case 0:
                    user?.setObject(userInputTextField.text!, forKey: "email")
                    save()
                case 1:
                    user?.setObject(userInputTextField.text!, forKey: "phone")
                    save()
                case 2:
                    user?.setObject(userInputTextField.text!, forKey: "netID")
                    save()
                default:
                    break
                }
            }
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func save(){
        let user = PFUser.currentUser()
        user!.saveInBackgroundWithBlock(){ (succeeded, error) -> Void in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                //If not successful, inform the user error occured
                let alert = UIAlertView(title: "Invalid", message: "Invalid Input, details have not been updated", delegate: self,cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
}
