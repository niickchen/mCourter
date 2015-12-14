//
//  UIViewControllerExtension.swift
//  Courter
//
//  Created by n3turn on 12/11/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorView(error: NSError) {
        if let errorMessage = error.userInfo["error"] as? String {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}