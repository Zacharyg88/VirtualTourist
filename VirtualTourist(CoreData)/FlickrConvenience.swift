//
//  FlickrConvenience.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/13/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import UIKit

extension FlickrClient {
    
    func getPhotosFromFlickr(lat: Float, lon: Float, convenienceMethodForGetPhotos: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        
        
        FlickrClient.sharedInstance().searchFlickrByLocation(lat: lat, lon: lon) { (success, results, error) in
            if error != "" {
                print(error)
                convenienceMethodForGetPhotos(false, error)
            }else {
                if results.count == 0 {
                    FlickrClient.Constants.FlickrUsables.noPhotosBool = true
                    convenienceMethodForGetPhotos(true, "no photos")
                }
                FlickrClient.Constants.FlickrUsables.photosArray = results
                convenienceMethodForGetPhotos(true, "")
            }
        }
    }
}
