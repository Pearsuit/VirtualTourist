//
//  SuccessAlert.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/16/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

// Error alert that will be displayed to the user
func successAlert(successMessage: String, UIViewController: UIViewController, completion: (() -> ())?) {
    
    let alert = UIAlertController(title: "Success", message: successMessage, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .cancel)
    
    alert.addAction(okAction)
    
    UIViewController.present(alert, animated: true) {
        
        if let completion = completion{
            
            completion()
            
        }
    }
}
