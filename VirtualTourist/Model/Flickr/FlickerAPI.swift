//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/4/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//
import UIKit

class FlickrAPI: NSObject {
    
    override init() {
        super.init()
    }
    
    //MARK: PARENT SEARCH FUNCTION
    
    //Creates an error that will then put in a completion handler that can then be displayed in an error alert to the user
    func sendError(_ error: String, domain: String, completion: (_ imageData: Data?, _ error: NSError?) -> Void) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completion(nil, NSError(domain: domain, code: 1, userInfo: userInfo))
    }
    
    //The parent search function to download images
    func searchByLatLon(latitide: Double, longitude: Double, completion: @escaping (_ imageData: Data?, _ error: NSError?) -> Void){
        
        let methodParameters = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitide, longitude: longitude),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
        displayImageFromFlickrBySearch(methodParameters as [String:AnyObject], completion: completion)
        
    }
    
    //Creates the coordinates necessary for the parent search function
    private func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    //MARK: CHILD SEARCH FUNCTIONS
    
    // Child search function that will generate a random page from the coordinate search function
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], completion: @escaping (_ imageData: Data?, _ error: NSError?) -> Void){
        
        print("random page search started")
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            
            guard let data = self.retrieveDataSecurely(data: data, response: response, error: error, domain: "getRandomPage", completion: completion) else {
                return
            }
            
            guard let photosDictionary = self.retrievePhotosDictionary(data: data as NSData, completion: completion) else {
                return
            }
            
            guard let randomPage = self.retrievePageNumber(photosDictionary: photosDictionary, completion: completion) else {
                return
            }
            
            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage, completion: completion)
        }
        
        task.resume()
        
    }
    
    //Child search function of the random page function that will retrieve a random photo from the random page given

    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int, completion: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) {
        
        print("photo search started")
        
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let data = self.retrieveDataSecurely(data: data, response: response, error: error, domain: "getRandomPhoto", completion: completion) else {
                return
            }
            
            guard let photosDictionary = self.retrievePhotosDictionary(data: data as NSData, completion: completion) else {
                return
            }
            
            self.retrievePhotoData(photosDictionary: photosDictionary, completion: completion)
            
        }
        
        task.resume()
    }
    
    //MARK: SINGLETON
    
    class func sharedInstance() -> FlickrAPI {
        struct Singleton {
            static var sharedInstance = FlickrAPI()
        }
        return Singleton.sharedInstance
    }
}
