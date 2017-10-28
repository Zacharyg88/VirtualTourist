//
//  photoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Zach Eidenberger on 10/5/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    
    @IBOutlet weak var mapView:MKMapView! // = MKMapView()
    @IBOutlet weak var photoCollectionView:UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    
    override func viewDidLoad() {
        super.viewDidLoad()        
        photoCollectionView?.delegate = self
        
        // Map Setup
        self.mapView?.camera.altitude = CLLocationDistance(UserDefaults.standard.float(forKey: "mapZoom"))
        self.mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.latitude), longitude: CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.longitude))
        let currentPinAnnotation = MKPointAnnotation()
        currentPinAnnotation.coordinate.latitude = CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.latitude)
        currentPinAnnotation.coordinate.longitude = CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.longitude)
        self.mapView?.addAnnotation(currentPinAnnotation)
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                pinView!.animatesDrop = true
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                pinView!.rightCalloutAccessoryView?.backgroundColor = UIColor.cyan
            }
            else {
                pinView!.annotation = annotation
            }
            return pinView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photoCollectionViewCell
        let photos = [(FlickrClient.Constants.FlickrUsables.currentPin.photo?.allObjects)]
        let photo = photos[(indexPath as IndexPath).row]
        //photo without image data 
        
        
        // activity indicator 
        
        // urlsession.datatask -> URL
        
        // data -> 1. photo.imagedata = data
        // UIIMage (data ) - cell.imageview.image = image
        
        print(photo)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (FlickrClient.Constants.FlickrUsables.currentPin.photo?.allObjects.count)!
    }
    
    
    
    
}


