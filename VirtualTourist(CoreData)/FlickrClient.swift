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
    
    func searchFlickrByLocation(lat: Float, lon: Float, completionHandlerForSearchFlickerByLocation: @escaping (_ results:[String: AnyObject], _ errorString: String) -> Void) {
        let session = URLSession.shared
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let latPredicate = NSPredicate(format: "latitude == %@", lat)
        let lonPredicate = NSPredicate(format: "longitude == %@", lon)
        //let latlonPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lonPredicate])
        //fetchRequest.predicate = latlonPredicate
        var currentPin = Pin()
        //print(currentPin)
        
        do {
            let fetchedPin = try context.fetch(fetchRequest)
            for pin in fetchedPin {
                if (pin as! Pin).latitude == lat && (pin as! Pin).longitude == lon {
                    currentPin = pin as! Pin
                }
                print(currentPin)
            }
            
        }catch {
            print("couldn't find current pin")
        }
        
        func bboxString() -> String {
            let minimumLon = max(lon - Constants.Flickr.bboxHalfWidth, Float(Constants.Flickr.SearchLonRange.0))
            let minimumLat = max(lat - Constants.Flickr.bboxHalfHeight, Float(Constants.Flickr.SearchLatRange.0))
            let maximumLon = min(lon + Constants.Flickr.bboxHalfWidth, Float(Constants.Flickr.SearchLonRange.1))
            let maximumLat = min(lat + Constants.Flickr.bboxHalfHeight, Float(Constants.Flickr.SearchLatRange.1))
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        }
        
        let methodParameters = [
            Constants.FlickrKeys.safeSearch: Constants.FlickerValues.useSafeSearch,
            Constants.FlickrKeys.boundingBox: bboxString(),
            Constants.FlickrKeys.apiKey: Constants.FlickerValues.APIKey,
            Constants.FlickrKeys.format: Constants.FlickerValues.responseFormat,
            Constants.FlickrKeys.method: Constants.FlickerValues.searchMethod,
            Constants.FlickrKeys.noJSONCallback: Constants.FlickerValues.disableJSONCallback
        ]
        
        func getImagesFromLocationSearch(_ methodParameters: [String: AnyObject]) {
            let session = URLSession.shared
            let request = URLRequest(url: flickrURLFromParameters(methodParameters))
            print(request.url!)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print("There was an error! \(error)")
                }else {

                    
                    var parsedResults = [String: AnyObject]()
                    do{
                        parsedResults = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                    }catch {
                        print("There was an Error parsing the JSON Data")
                        return
                    }
                    
                    let photos = parsedResults["photos"] as! [String: AnyObject]
                    let photoArray = photos["photo"] as! [[String: AnyObject]]
                    print(photoArray)
                    for photo in photoArray {
                        let farm = String(describing: photo["farm"]!)
                        let id = photo["id"] as! String
                        let server = photo["server"] as! String
                        let secret = photo["secret"] as! String
                        print(farm, id, server, secret)
                        
                        
                        let photoURL = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
                        print("\(photoURL)")
                        
                        let photoImageData = NSData(contentsOf: photoURL!)
                        let newPhoto = Photo(id: (Double(id)!), image: photoImageData!, title: photo["title"] as! String, pin: currentPin , context: context)
                        print(newPhoto)
                        
                    }
                    
                }
                
                
            }
            task.resume()
        }
        getImagesFromLocationSearch(methodParameters as [String : AnyObject])
        
        
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

