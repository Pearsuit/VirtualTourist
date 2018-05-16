//
//  MapViewExtenison.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/15/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit
import CoreData
import MapKit

extension MapVC {
    
    //Creates Custom MKAnnotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        guard annotationView == nil  else {
            annotationView!.annotation = annotation
            return annotationView
        }
        
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        annotationView?.pinTintColor = UIColor(displayP3Red: 1/255, green: 203/255, blue: 187/255, alpha: 1)
        annotationView?.animatesDrop = true
        
        return annotationView
    }
    
    //Either deletes or presents info of the annotation selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //Deletes the annotation
        if deleteLabelVisible {
            
            guard let managedContext = createNSManagedObjectContext() else {
                return
            }
            
            let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            
            guard let selectedPin = view.annotation else {
                errorAlert(alertMessage: "Error found while attempting to delete pin", UIViewController: self, completion: nil)
                return
            }
            
            pinRequest.predicate = createPinPredicate(latitude: selectedPin.coordinate.latitude, longitude: selectedPin.coordinate.longitude)
            
            do {
                predicatedPin = try managedContext.fetch(pinRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            pin = predicatedPin[0]
            
            managedContext.delete(pin)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            mapView.deselectAnnotation(view.annotation, animated: true)
            mapView.removeAnnotation(selectedPin)
        } else {
            
            //Presents the info of the annotation in another view controller
            mapView.deselectAnnotation(view.annotation, animated: true)
            guard let annotation = view.annotation else {
                
                errorAlert(alertMessage: "Unable to display photos", UIViewController: self, completion: nil)
                return
            }
            
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PinInfo") as? PinInfoVC {
                
                viewController.latitude = annotation.coordinate.latitude
                viewController.longitude = annotation.coordinate.longitude
                
                if let navigator = navigationController {
                    
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}
