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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    @IBAction func dismissPhotoCollectionViewController(_ sender: Any) {
        self.dismiss(animated: true) {
            FlickrClient.Constants.FlickrUsables.currentPin = Pin()
            FlickrClient.Constants.FlickrUsables.photosArray = []
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        
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
        cell.photoActivityIndicator.isHidden = false
        cell.photoActivityIndicator.startAnimating()
        let photos = FlickrClient.Constants.FlickrUsables.photosArray
        print(photos)
        
        for photo in photos {
            print(photo)
            
            let photoURL = photo.imageURL
            let session = URLSession.shared
            let request = URLRequest(url: URL(string: photoURL!)!)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error)
                }else {
                    let imageData = data
                    print(imageData)
                    
                    cell.photoImageView?.image = UIImage(data: imageData!)
                    cell.photoActivityIndicator.isHidden = true
                    cell.photoActivityIndicator.stopAnimating()
                }
            }
        task.resume()
        }
            return cell
    }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return (FlickrClient.Constants.FlickrUsables.currentPin.photo?.allObjects.count)!
        }
}


