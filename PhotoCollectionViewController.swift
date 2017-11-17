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

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var photoCollectionView:UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var noPhotosView: UIView!
    
    //var photosArray = [Photo]()
    var pinID = NSManagedObjectID()
    var noPhotosBool = Bool()
    var fetchedResults = [Photo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deletedPhotosIndexPaths = [IndexPath]()
    
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            fetchedResultsController?.delegate = self
            fetchResults()
            self.photoCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        noPhotosView.isHidden = true
        super.viewDidLoad()
        let currentPin = fetchedResultsController?.managedObjectContext.object(with: FlickrClient.Constants.Flickr.currentPinObjectID)
        
        let photoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let photoPredicate = NSPredicate(format: "pin = %@", currentPin!)
        let sort = NSSortDescriptor(key: "id", ascending: false)
        photoRequest.sortDescriptors = [sort]
        photoRequest.predicate = photoPredicate
        fetchedResults = try! context.fetch(photoRequest) as! [Photo]
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        let frc = NSFetchedResultsController(fetchRequest: photoRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = frc
        
        // Map Setup
        self.mapView?.camera.altitude = CLLocationDistance(12000)
        self.mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentPin.latitude), longitude: CLLocationDegrees(currentPin.longitude))
        let currentPinAnnotation = MKPointAnnotation()
        currentPinAnnotation.coordinate.latitude = CLLocationDegrees(currentPin.latitude)
        currentPinAnnotation.coordinate.longitude = CLLocationDegrees(currentPin.longitude)
        self.mapView?.addAnnotation(currentPinAnnotation)
    }
    
    func fetchResults() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            }catch {
                print(error)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func dismissPhotoCollectionViewController(_ sender: Any) {
        self.dismiss(animated: true) {
            FlickrClient.Constants.Flickr.currentPinObjectID = nil
        }
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        deletedPhotosIndexPaths.removeAll()
        for photo in (fetchedResultsController?.fetchedObjects)! {
            fetchedResultsController?.managedObjectContext.delete(photo as! NSManagedObject)
        }
        FlickrClient.sharedInstance().getPhotosFromFlickr(lat: Float(mapView.annotations[0].coordinate.latitude), lon: Float(mapView.annotations[0].coordinate.longitude)) { (success, error) in
            if success != true {
                print(error)
            }else {
                self.photoCollectionView.reloadData()
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletedPhotosIndexPaths.removeAll()
        deletedPhotosIndexPaths.append(indexPath)
        deletePhoto()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        deletedPhotosIndexPaths = [IndexPath]()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete {
            deletedPhotosIndexPaths.append(indexPath!)
        }
        try! fetchedResultsController?.performFetch()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        for indexPath in deletedPhotosIndexPaths {
            self.photoCollectionView.deleteItems(at: [indexPath])
        }
        photoCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (fetchedResultsController?.sections?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = fetchedResultsController?.sections![section]
        return (sectionData?.numberOfObjects)!
    }
    
    func deletePhoto() {
        var photo = [Photo]()
        for index in deletedPhotosIndexPaths {
            photo.append(fetchedResultsController?.object(at: index) as! Photo)
        }
        for photo in photo {
            fetchedResultsController?.managedObjectContext.delete(photo)
        }
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
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
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
}
