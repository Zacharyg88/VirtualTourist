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
    var currentPin = [Pin]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    
    func searchFlickrByLocation(lat: Float, lon: Float, completionHandlerForSearchFlickerByLocation: @escaping (_ success: Bool,_ results: [Photo], _ errorString: String) -> Void) {
        let methodParameters = [
            Constants.FlickrKeys.safeSearch: Constants.FlickerValues.useSafeSearch,
            Constants.FlickrKeys.boundingBox: bboxString(lat: lat, lon: lon),
            Constants.FlickrKeys.apiKey: Constants.FlickerValues.APIKey,
            Constants.FlickrKeys.format: Constants.FlickerValues.responseFormat,
            Constants.FlickrKeys.method: Constants.FlickerValues.searchMethod,
            Constants.FlickrKeys.noJSONCallback: Constants.FlickerValues.disableJSONCallback,
            Constants.FlickrKeys.perPage: Constants.FlickerValues.perPage,
            Constants.FlickrKeys.page: getRandomPageNumber(number: 10)
        ]
        
        
        let fetchPin = NSFetchRequest<Pin>(entityName: "Pin")
        let latPredicate = NSPredicate(format: "latitude = %f", lat)
        let lonPredicate = NSPredicate(format: "longitude = %f", lon)
        fetchPin.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lonPredicate])
        currentPin = try! context.fetch(fetchPin)
        getImagesFromLocationSearch(methodParameters as [String : AnyObject]) { (success, results) in
            if success == true {
                completionHandlerForSearchFlickerByLocation(true, results, "")
            }
        }
    }
    
    func getRandomPageNumber(number: Int) -> String {
        let randomNumber = Int(arc4random_uniform(UInt32(number)))
        let randomNumberString = String(randomNumber)
        return randomNumberString
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
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("There was an error! \(error)")
                completionHandlerForGetImagesFromLocationSearch(false, [])
                
            }else {
                var parsedResults = [String: AnyObject]()
                do{
                    parsedResults = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                }
                let photos = parsedResults["photos"] as! [String: AnyObject]
                let photoArray = photos["photo"] as! [[String: AnyObject]]
                
                DispatchQueue.main.async {
                    for photo in photoArray {
                      
                            let farm = String(describing: photo["farm"]!)
                            let id = photo["id"] as! String
                            let server = photo["server"] as! String
                            let secret = photo["secret"] as! String
                            let photoURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                            let newPhoto = Photo.init(id: (Double(id))!, imageURL: photoURL, title: photo["title"] as! String, pin: self.currentPin[0] , context: self.context)
                            results.append(newPhoto)
                    }
                     (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    
                    
                }
                completionHandlerForGetImagesFromLocationSearch(true, results)
            }
        }
        task.resume() // two threads
    }
    
    func downloadImageDataFromFlickr(urlString: String, photo: Photo, completionHandlerDownloadImageFromFlickr: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: URL(string: urlString)!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandlerDownloadImageFromFlickr(false, "\(error)")
            }else {
                photo.imageData = data as NSData?
            }
            completionHandlerDownloadImageFromFlickr(true, "")
        }
        task.resume()
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
}

