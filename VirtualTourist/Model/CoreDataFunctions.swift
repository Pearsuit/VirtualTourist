//
//  CoreDataFunctions.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/14/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit
import CoreData

//MARK: MANAGED OBJECT CONTEXT CREATOR
func createNSManagedObjectContext() -> NSManagedObjectContext?{
    
    guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return nil
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    return managedContext
}

//MARK: PIN PREDICATE CREATOR
func createPinPredicate(latitude: Double, longitude: Double) -> NSCompoundPredicate {
    
    let latitudeKeyPath = "latitude"
    let latitudeSearchString = String(latitude)
    
    let longitudeKeyPath = "longitude"
    let longitudeSearchString = String(longitude)
    
    let latitudePredicate = NSPredicate(format: "%K CONTAINS %@", latitudeKeyPath, latitudeSearchString)
    let longitudePredicate = NSPredicate(format: "%K CONTAINS %@", longitudeKeyPath, longitudeSearchString)
    let coordinatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate])
    
    return coordinatePredicate
    
}
