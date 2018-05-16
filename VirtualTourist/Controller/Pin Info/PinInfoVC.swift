//
//  PinInfoVC.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 9/13/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinInfoVC: UIViewController {
    
    @IBOutlet weak var collectionButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var annotationPhotoArray = [Photo]()
    var predicatedPin = [Pin]()
    var pin = Pin()
    var latitude: Double!
    var longitude: Double!
    
    let placeHolderData: Data = UIImagePNGRepresentation(#imageLiteral(resourceName: "square_label_blue"))!
    
    var selectedPhotos = [IndexPath : Photo]() {
        didSet {
            collectionButton.title = selectedPhotos.count > 0 ? "Delete Selected Photos" : "New Collection"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        
        guard let managedContext = createNSManagedObjectContext() else {
            return
        }
        
        let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        pinRequest.predicate = createPinPredicate(latitude: latitude, longitude: longitude)
        
        do {
            predicatedPin = try managedContext.fetch(pinRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        pin = predicatedPin[0]
        
        performUIUpdatesOnMain {
            
            self.mapView.layer.cornerRadius = 5
            
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.latitude, self.longitude), span: span)
            self.mapView.setRegion(region, animated: true)
            
            let pinLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            let objectAnn = MKPointAnnotation()
            objectAnn.coordinate = pinLocation
            self.mapView.addAnnotation(objectAnn)
            
        }
        
        displayImages(pin: pin)
        
        if pin.photo?.count == 0 {
            createACollection()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFlowLayout()
        //Updates collection view cell dimensions if rotation changes
        NotificationCenter.default.addObserver(self, selector: #selector(PinInfoVC.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func displayImages(pin: Pin) {
        
        annotationPhotoArray.removeAll()
        
        guard let photoSet = pin.photo as? Set<Photo>, !photoSet.isEmpty else {
            return
        }
        
        for photo in photoSet {
            annotationPhotoArray.append(photo)
        }
    }

    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            setFlowLayout()
        } else {
            setFlowLayout()
        }
    }
    
    func setFlowLayout() {
        
        let dimension = self.view.frame.size.width / 3
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    func createACollection() {
        
        var savedPhotosCounter = 0
        
        collectionButton.isEnabled = false
        
        let annotation = pin
        
        guard let photosToDelete = annotation.photo as? Set<Photo> else {
            errorAlert(alertMessage: "There was no collection of photos to delete", UIViewController: self, completion: nil)
            return
        }
        
        guard let managedContext = createNSManagedObjectContext() else {
            return
        }
        
        for photo in photosToDelete {
            managedContext.delete(photo)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        annotationPhotoArray.removeAll()
        collectionView.reloadData()
        
        
        for i in 0...20 {
            
            let photo = Photo(context: managedContext)
            
            photo.imageData = placeHolderData
            
            self.annotationPhotoArray.append(photo)
            
            self.collectionView.reloadData()
            
            FlickrAPI.sharedInstance().searchByLatLon(latitide: latitude, longitude: longitude, completion: { (data, error) in
                
                guard error == nil else {
                    
                    self.annotationPhotoArray.removeAll()
                    
                    performUIUpdatesOnMain {
                        
                        errorAlert(alertMessage: "\(error!.localizedDescription)", UIViewController: self, completion: nil)
                        self.collectionView.reloadData()
                        self.collectionButton.isEnabled = true
                        
                    }
                    return
                }
                
                guard let imageData = data else{
                    
                    performUIUpdatesOnMain {
                        errorAlert(alertMessage: "No photo data could be found", UIViewController: self, completion: nil)
                        self.collectionButton.isEnabled = true
                    }
                    return
                }
                
                photo.imageData = imageData
                
                annotation.addToPhoto(photo)
                self.annotationPhotoArray.remove(at: i)
                self.annotationPhotoArray.insert(photo, at: i)
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                performUIUpdatesOnMain {
                    
                    savedPhotosCounter += 1
                    
                    print("performed reload")
                    self.collectionView.reloadItems(at: [[0, i]])
                    self.collectionButton.isEnabled = (savedPhotosCounter == 21) ? true : false
                    
                }
                
            })
        }
        
        
    }
    
    
    @IBAction func createANewCollectionForAnnotation(_ sender: UIBarButtonItem) {
        
        //Creates a new collection of photos
        
        if collectionButton.title == "New Collection" {
            
            createACollection()
            
        //Deletes selected photos
        } else {
            
            guard let managedContext = createNSManagedObjectContext() else {
                return
            }
            
            for indexPath in selectedPhotos {
                
                guard let arrayIndex = annotationPhotoArray.index(of: indexPath.value) else {
                    errorAlert(alertMessage: "Unable to delete photo", UIViewController: self, completion: nil)
                    break
                }
                annotationPhotoArray.remove(at: arrayIndex)

                
                managedContext.delete(indexPath.value)
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
            collectionView.reloadData()
            selectedPhotos.removeAll()
        }
    }
}
