//
//  ErrorAlert.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/14/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

// Error alert that will be displayed to the user
func errorAlert(alertMessage: String, UIViewController: UIViewController, completion: (() -> ())?) {
    
    let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .cancel)
    
    alert.addAction(okAction)
    
    UIViewController.present(alert, animated: true) {
        
        if let completion = completion{
            
            completion()
            
        }
    }
}
