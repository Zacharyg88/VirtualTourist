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
    
    var photosArray = [Photo]()
    
    @IBAction func dismissPhotoCollectionViewController(_ sender: Any) {
        self.dismiss(animated: true) {
            FlickrClient.Constants.FlickrUsables.currentPin = Pin()
            FlickrClient.Constants.FlickrUsables.photosArray = []
        }
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        var pinID = NSManagedObjectID()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let photoFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let pinFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let fetchedPhotos = try! context.fetch(photoFetchRequest) as! [Photo]
        let fetchedPins = try! context.fetch(pinFetchRequest) as! [Pin]
        for pin in fetchedPins {
            if pin.latitude == Float(self.mapView.centerCoordinate.latitude) && pin.longitude == Float(self.mapView.centerCoordinate.longitude) {
                pinID = pin.objectID
            }
        }
        for photo in fetchedPhotos {
            if photo.pin?.objectID == pinID {
                context.delete(photo)
            }
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.viewDidLoad()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        var currentPin: Pin
        let fetchedPins = try! context.fetch(request) as! [Pin]
        for pin in fetchedPins {
            if pin.longitude == (FlickrClient.Constants.FlickrUsables.currentPin.longitude) && pin.latitude == (FlickrClient.Constants.FlickrUsables.currentPin.latitude) {
                currentPin = pin
                let photoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                let fetchedPhotos = try! context.fetch(photoRequest) as! [Photo]
                for photo in fetchedPhotos {
                    if photo.pin == currentPin {
                        photosArray.append(photo)
                    }
                }
            }
        }
        
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        
        // Map Setup
        self.mapView?.camera.altitude = CLLocationDistance(12000)
        self.mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.latitude), longitude: CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.longitude))
        let currentPinAnnotation = MKPointAnnotation()
        currentPinAnnotation.coordinate.latitude = CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.latitude)
        currentPinAnnotation.coordinate.longitude = CLLocationDegrees(FlickrClient.Constants.FlickrUsables.currentPin.longitude)
        self.mapView?.addAnnotation(currentPinAnnotation)
    }
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! photoCollectionViewCell
        cell.photoActivityIndicator.isHidden = false
        cell.photoActivityIndicator.startAnimating()
        let photo = self.photosArray[(indexPath as IndexPath).row]
        let photoURL = photo.imageURL
        let session = URLSession.shared
        let request = URLRequest(url: URL(string: photoURL!)!)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error)
            }else {
                let imageData = data
                cell.photoImageView?.image = UIImage(data: imageData!)
                cell.photoActivityIndicator.isHidden = true
                cell.photoActivityIndicator.stopAnimating()
            }
        }
        task.resume()
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (FlickrClient.Constants.FlickrUsables.currentPin.photo?.allObjects.count)!
    }
}



