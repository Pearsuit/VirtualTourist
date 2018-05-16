//
//  HelperFunctions.swift
//  VirtualTourist
//
//  Created by Nathaniel Dillinger on 10/14/17.
//  Copyright © 2017 Nathaniel Dillinger. All rights reserved.
//

import UIKit

extension FlickrAPI {
    
    //MARK: URL CREATOR
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //MARK: DATA RETRIEVER
    
    func retrieveDataSecurely(data: Data?, response: URLResponse?, error: Error?, domain: String, completion: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) -> Data? {
        
        guard (error == nil) else {
            
            sendError("There was an error with your request: \(error!.localizedDescription)", domain: "retrieveDataSecurely", completion: completion)
            return nil
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            sendError("Your request returned a status code other than 2xx!: \(statusCode)", domain: "retrieveDataSecurely", completion: completion)
            return nil
        }
        
        guard let data = data else {
            sendError("No data was returned by the request!", domain: "retrieveDataSecurely", completion: completion)
            return nil
        }
        
        return data
        
    }
    
}
