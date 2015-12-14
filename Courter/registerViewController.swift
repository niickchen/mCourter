//
//  registerViewController.swift
//  Courter
//
//  Created by Kai Li on 12/13/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

class registerViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var netIDTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        
        if(userTextField.text!.isEmpty || passwordTextField.text!.isEmpty){
            var alert = UIAlertView(title: "Invalid", message: "Username or Password cannot be left empty.", delegate: self,cancelButtonTitle: "OK")
            alert.show()
        }
        else if(emailTextField.text!.isEmpty || phoneTextField.text!.isEmpty || fullNameTextField.text!.isEmpty){
            var alert = UIAlertView(title: "Invalid", message: "Name, Phone or Email cannot be left empty.", delegate: self,cancelButtonTitle: "OK")
            alert.show()
        }
        else{
            let user = PFUser()
            // Assign Username and Password to PFUser object
            user.username = userTextField.text
            user.password = passwordTextField.text
            user.email = emailTextField.text
            
            user.setObject(phoneTextField.text!, forKey: "phone")
            user.setObject(netIDTextField.text!, forKey: "netID")
            user.setObject(bioTextField.text!, forKey: "Bio")
            user.setObject(fullNameTextField.text!, forKey: "fullName")
            
            user.signUpInBackgroundWithBlock { succeeded, error in
                if (succeeded) {
                    self.performSegueWithIdentifier("SignUpSuccessful", sender: nil)
                } else if let error = error {
                    //Something bad has occurred
                    self.showErrorView(error)
                }
            }
        }
    }
    
}
