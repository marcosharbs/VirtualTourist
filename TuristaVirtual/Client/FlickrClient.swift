//
//  FlickrClient.swift
//  TuristaVirtual
//
//  Created by Marcos Harbs on 19/08/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static let client = FlickrClient()
    
    func getPhotos(pin: Pin, completionHandler: @escaping (_ photosUrls: [String]?, _ error: Error?) -> Void) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(pin),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String:AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 1, userInfo: nil))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 2, userInfo: nil))
                }
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 3, userInfo: nil))
                }
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 4, userInfo: nil))
                }
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 5, userInfo: nil))
                }
                return
            }
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 6, userInfo: nil))
                }
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            var methodParametersWithPageNumber = methodParameters as [String:AnyObject]
            methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = randomPage as AnyObject?
            
            let session = URLSession.shared
            let request = URLRequest(url: self.flickrURLFromParameters(methodParametersWithPageNumber as [String:AnyObject]))
            
            let task = session.dataTask(with: request) { (data, response, error) in
                guard (error == nil) else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 7, userInfo: nil))
                    }
                    return
                }
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 8, userInfo: nil))
                    }
                    return
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 9, userInfo: nil))
                    }
                    return
                }
                
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 10, userInfo: nil))
                    }
                    return
                }
                
                guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 11, userInfo: nil))
                    }
                    return
                }
                
                guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 12, userInfo: nil))
                    }
                    return
                }
                
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 13, userInfo: nil))
                    }
                    return
                }
                
                if photosArray.count == 0 {
                    DispatchQueue.main.async {
                        completionHandler(nil, nil)
                    }
                    return
                } else {
                    if photosArray.count == 0 {
                        DispatchQueue.main.async {
                            completionHandler([], nil)
                        }
                        return
                    }
                    var urls: [String] = []
                    for index in 0...20 {
                        if index < photosArray.count {
                            urls.append(photosArray[index][Constants.FlickrResponseKeys.MediumURL] as! String)
                        }
                    }
                    DispatchQueue.main.async {
                        completionHandler(urls, nil)
                    }
                    return
                }
            }
            
            task.resume()
        }
        
        task.resume()
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
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
    
    private func bboxString(_ pin: Pin) -> String {
        let latitude = Double(pin.x)
        let longitude = Double(pin.y)
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}
