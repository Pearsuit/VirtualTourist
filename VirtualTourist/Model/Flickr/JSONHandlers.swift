//
//  JSONHandlers.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/14/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

extension FlickrAPI {
    
    //MARK: PHOTO DICTIONARY RETRIEVER
    
    func retrievePhotosDictionary(data: NSData, completion: (_ imageData: Data?, _ error: NSError?) -> Void) -> [String: AnyObject]?{
        
        var parsedResult: [String: AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completion(nil, NSError(domain: "convert", code: 1, userInfo: userInfo))
        }
        
        guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            sendError("Flickr API returned an error. See error code and message in \(parsedResult)", domain: "retrievePhotosDictionary", completion: completion)
            return nil
        }
        
        /* GUARD: Is "photos" key in our result? */
        guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
            sendError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)", domain: "retrievePhotosDictionary", completion: completion)
            return nil
        }
        
        return photosDictionary
    }
    
    //MARK: RANDOM PAGE NUMBER RETRIEVER
    
    func retrievePageNumber(photosDictionary: [String: AnyObject], completion: (_ imageData: Data?, _ error: NSError?) -> Void) -> Int? {
        
        guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
            sendError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)", domain: "retrievePhotosDictionary", completion: completion)
            return nil
        }
        
        // pick a random page!
        let pageLimit = min(totalPages, 40)
        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
        
        return randomPage
    }
    
    //MARK: RANDOM PHOTO RETRIEVER
    
    func retrievePhotoData(photosDictionary: [String: AnyObject], completion: (_ imageData: Data?, _ error: NSError?) -> Void){
        
        var myImageData: Data?
        
        guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
            self.sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)", domain: "retrievePhotoData", completion: completion)
            return
        }
        
        if photosArray.count == 0 {
            self.sendError("No Photos Found. Search Again or Try Another Location.", domain: "retrievePhotoData", completion: completion)
            return
        } else {
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                self.sendError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)", domain: "retrievePhotoData", completion: completion)
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                
                myImageData = imageData
                print(myImageData)
                
            } else {
                self.sendError("Image does not exist at \(imageURL)", domain: "retrievePhotoData", completion: completion)
            }
            
            completion(myImageData, nil)
        }
    }
}
