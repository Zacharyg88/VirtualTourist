//
//  FlickrClient.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/13/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Zach Eidenberger on 10/4/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import UIKit
import CoreData

class FlickrClient: NSObject {
    var currentPinID = NSManagedObjectID()
    var currentPinLat = Float()
    var currentPinLon = Float()
    
    
    func searchFlickrByLocation(lat: Float, lon: Float, completionHandlerForSearchFlickerByLocation: @escaping (_ success: Bool,_ results: [Photo], _ errorString: String) -> Void) {
        let methodParameters = [
            Constants.FlickrKeys.safeSearch: Constants.FlickerValues.useSafeSearch,
            Constants.FlickrKeys.boundingBox: bboxString(lat: lat, lon: lon),
            Constants.FlickrKeys.apiKey: Constants.FlickerValues.APIKey,
            Constants.FlickrKeys.format: Constants.FlickerValues.responseFormat,
            Constants.FlickrKeys.method: Constants.FlickerValues.searchMethod,
            Constants.FlickrKeys.noJSONCallback: Constants.FlickerValues.disableJSONCallback
        ]
        getImagesFromLocationSearch(methodParameters as [String : AnyObject]) { (success, results) in
            if success == true {
                completionHandlerForSearchFlickerByLocation(true, results, "")
            }
        }
    }
    func bboxString(lat: Float, lon: Float) -> String {
        let minimumLon = max(lon - Constants.Flickr.bboxHalfWidth, Float(Constants.Flickr.SearchLonRange.0))
        let minimumLat = max(lat - Constants.Flickr.bboxHalfHeight, Float(Constants.Flickr.SearchLatRange.0))
        let maximumLon = min(lon + Constants.Flickr.bboxHalfWidth, Float(Constants.Flickr.SearchLonRange.1))
        let maximumLat = min(lat + Constants.Flickr.bboxHalfHeight, Float(Constants.Flickr.SearchLatRange.1))
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func getImagesFromLocationSearch(_ methodParameters: [String: AnyObject], completionHandlerForGetImagesFromLocationSearch: @escaping (_ success: Bool,_ results: [Photo] ) -> Void) {
        let session = URLSession.shared
        var results = [Photo]()
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("There was an error! \(error)")
            }else {
                var parsedResults = [String: AnyObject]()
                do{
                    parsedResults = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                }
                let photos = parsedResults["photos"] as! [String: AnyObject]
                let photoArray = photos["photo"] as! [[String: AnyObject]]
                self.getCDPins()
                
                for photo in photoArray {
                    context.perform {
                        let currentPinID = context.object(with: self.currentPinID)
                        
                        let farm = String(describing: photo["farm"]!)
                        let id = photo["id"] as! String
                        let server = photo["server"] as! String
                        let secret = photo["secret"] as! String
                        let photoURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                        let newPhoto = Photo.init(id: (Double(id))!, imageURL: photoURL, title: photo["title"] as! String, pin: currentPinID as! Pin, context: context)
                        results.append(newPhoto)
                        FlickrClient.Constants.FlickrUsables.photosArray.append(newPhoto)
                    }
                }
            }
        }
        task.resume()
    
        completionHandlerForGetImagesFromLocationSearch(true, results)
        
    }
    
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
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func getCDPins() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let requestResults = try! context.fetch(request) as! [Pin]
        for result in requestResults {
            let lat = Float(result.latitude)
            let lon = Float(result.longitude)
            
            if lat == FlickrClient.Constants.FlickrUsables.currentPin.latitude && lon == FlickrClient.Constants.FlickrUsables.currentPin.longitude {
                self.currentPinID = result.objectID
                print(self.currentPinID)
                
            }
        }
    }
    
}

