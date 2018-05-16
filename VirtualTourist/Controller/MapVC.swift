//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 9/14/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate {
    
    //MARK: IB OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadingLabel: UILabel!
    
    //MARK: VARIABLES
    var predicatedPin = [Pin]()
    var pin = Pin()
    var annotations = [Pin]()
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    var deleteLabelVisible = false
    
    //MARK: LOAD AND APPEAR FUNCTIONS
    override func viewDidLoad() {
        
        loadingActivityIndicator.hidesWhenStopped = true
        loadingActivityIndicator.stopAnimating()
        downloadingLabel.alpha = 0
        
        mapView.delegate = self
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation))
        
        self.mapView.addGestureRecognizer(tap)
        
        deleteLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
        deleteLabel.textColor = .white
        deleteLabel.backgroundColor = .red
        deleteLabel.textAlignment = .center
        deleteLabel.text = "Tap Pin to Delete"
        
        reloadDataForMap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Updates collection view cell dimensions if rotation changees
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    //MARK: FUNCTIONS
    
    // Validates that the location has photos, and if so, saves the pin
    func savePin(latitude: Double, longitude: Double, mapAnnotation: MKAnnotation) {
        guard let managedContext = createNSManagedObjectContext() else {
            return
        }
        
        var annotation = Pin()
        
        loadingActivityIndicator.startAnimating()
        mapView.isUserInteractionEnabled = false
        mapView.alpha = 0.5
        downloadingLabel.alpha = 1
        
        FlickrAPI.sharedInstance().searchByLatLon(latitide: latitude, longitude: longitude, completion: { (data, error) in
            
            guard error == nil else {
                errorAlert(alertMessage: "\(error!.localizedDescription)", UIViewController: self, completion: nil)
                performUIUpdatesOnMain {
                    self.mapView.removeAnnotation(mapAnnotation)
                }
                self.restoreUI()
                return
            }
            
            guard let imageData = data else{
                errorAlert(alertMessage: "No photo data could be found", UIViewController: self, completion: nil)
                self.restoreUI()
                return
            }
                
            annotation = Pin(context: managedContext)
            annotation.latitude = latitude
            annotation.longitude = longitude
                
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            self.annotations.append(annotation)
            self.restoreUI()
            successAlert(successMessage: "Location is valid for photo search", UIViewController: self, completion: nil)
        })
    }
    
    //Returns the UI to original state
    func restoreUI() {
        
        performUIUpdatesOnMain {
            
            self.loadingActivityIndicator.stopAnimating()
            self.mapView.isUserInteractionEnabled = true
            self.mapView.alpha = 1
            self.downloadingLabel.alpha = 0
        }
        
    }
    
    //The function called when device orientation changes
    @objc func rotated() {
        deleteLabel.frame.size.width = self.view.frame.size.width
        
        if deleteLabelVisible {
            view.center.y -= deleteLabel.frame.size.height
        }
    }
    
    //Adds annotation to the mapView
    @objc func addAnnotation(_ gesture: UILongPressGestureRecognizer){
        
        if !deleteLabelVisible {
            
            if gesture.state == .began {

                let touchedAt = gesture.location(in: self.mapView)
                let newCoordinates : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)

                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinates
                mapView.addAnnotation(annotation)

                self.savePin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, mapAnnotation: annotation)
            }
        }
    }
    
    func reloadDataForMap() {
        
        guard let managedContext = createNSManagedObjectContext() else {
            return
        }
        
        let personRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            annotations = try managedContext.fetch(personRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for annotation in annotations {
            
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate.latitude = annotation.latitude
            mapAnnotation.coordinate.longitude = annotation.longitude
            self.mapView.addAnnotation(mapAnnotation)
            
        }
        
        annotations.removeAll()
    }
    
    @IBAction func deletePins(_ sender: UIBarButtonItem) {
        
        deleteLabelVisible = !deleteLabelVisible
        
        UIView.animate(withDuration: 0.5) {
            
            self.view.frame.origin.y = self.deleteLabelVisible ? self.view.frame.origin.y - 80 : self.view.frame.origin.y + 80
            
        }
    }
}

