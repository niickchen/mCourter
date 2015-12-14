//
//  logInViewController.swift
//  Courter
//
//  Created by n3turn on 12/12/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit
import Parse

class logInViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func loginInPress(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(userNameTextField.text!, password: passWordTextField.text!) { (user, error) in
            if user != nil {
                self.performSegueWithIdentifier("fromLoginToTabBar", sender: nil)
            } else if let error = error {
                self.showErrorView(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        if let user = PFUser.currentUser() {
            if user.authenticated {
                self.performSegueWithIdentifier("fromLoginToTabBar", sender: nil)
            }
        }
        
        // Do any additional setup after loading the view.
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