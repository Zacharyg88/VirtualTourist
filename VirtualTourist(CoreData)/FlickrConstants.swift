//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Zach Eidenberger on 10/4/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import UIKit
import CoreData
extension FlickrClient {
    
    struct Constants {
        
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLonRange = (-180.0, 180.0)
            static let bboxHalfWidth = Float(0.5)
            static let bboxHalfHeight = Float(0.5)
            static var  photosDictionary = [String: AnyObject]()
            static var currentPinObjectID: NSManagedObjectID!
        }
        
        struct FlickrKeys {
            static let apiKey = "api_key"
            static let method = "method"
            static let extras = "extras"
            static let format = "format"
            static let noJSONCallback = "nojsoncallback"
            static let safeSearch = "safe_search"
            static let text = "text"
            static let page = "page"
            static let boundingBox = "bbox"
            static let perPage = "per_page"
            
        }
        
        struct FlickerValues {
            static let searchMethod = "flickr.photos.search"
            static let APIKey = "943a1b5634907fbcd4f27d59dc2ed5d9"
            static let responseFormat = "json"
            static let disableJSONCallback = "1"
            static let galleryPhotosMethod = "flickr.galleries.getPhotos"
            static let galleryID = "5704-72157622566655097"
            static let mediumURL = "url_m"
            static let useSafeSearch = "1"
            static let perPage = "36"
            static let page = ""
            
            
        }
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let mediumURL = "url_m"
            static let pages = "pages"
            static let total = "total"
            
        }
//        struct FlickrUsables {
//            static var photosArray = [Photo]()
//            static var currentPinLat = Float()
//            static var currentPinLon = Float()
//            static var currentPin: Pin!
//            static var noPhotosBool = Bool()
//        }
        
    }
}
