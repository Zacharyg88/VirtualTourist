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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var noPhotosView: UIView!
    
    var pinID = NSManagedObjectID()
    var noPhotosBool = Bool()
    var fetchedResults = [Photo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var shouldReloadCollectionView = Bool()
    var deletedIndexes = [IndexPath]()
    var blockOperations = [BlockOperation]()
    var deleteAllBool = Bool()
    
    
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
        //photoCollectionView.setCollectionViewLayout(photoCollectionViewFlowLayout, animated: true)
        var currentPin: Pin!
        let fetchPin = NSFetchRequest<Pin>(entityName: "Pin")
        let fetchedPins = try! context.fetch(fetchPin)
        for pin in fetchedPins {
            if pin.objectID == FlickrClient.Constants.Flickr.currentPinObjectID {
                currentPin = pin
            }
        }
        print(currentPin.latitude, currentPin.longitude)
        
        let photoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let photoPredicate = NSPredicate(format: "pin = %@", currentPin)
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
        var deletePhotos = [Photo]()
        deleteAllBool = true
        var indexsToDelete = [IndexPath]()
        for section in 0..<photoCollectionView.numberOfSections {
            for index in 0..<photoCollectionView.numberOfItems(inSection: section) {
                indexsToDelete.append(IndexPath(item: index, section: section))
            }
        }
        
        print(indexsToDelete.count)
        print(fetchedResultsController?.fetchedObjects?.count)
        
        for index in indexsToDelete {
            deletePhotos.append(fetchedResultsController?.object(at: index) as! Photo)
        }
        for photo in deletePhotos {
            fetchedResultsController?.managedObjectContext.delete(photo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController?.object(at: indexPath)
        fetchedResultsController?.managedObjectContext.delete(photo as! Photo)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            print("insert@\(indexPath)")
            if (photoCollectionView.numberOfSections) > 0 {
                if photoCollectionView.numberOfItems(inSection: newIndexPath!.section) == 0 {
                    self.shouldReloadCollectionView = true
                }else {
                    if deleteAllBool == true {
                        blockOperations.append(
                            BlockOperation(block: { [weak self] in
                                if let this = self {
                                    this.photoCollectionView.insertItems(at: [indexPath!])
                                }
                                
                            })
                        )
                    }else {
                        self.photoCollectionView.insertItems(at: [indexPath!])
                    }
                }
            } else {
                self.shouldReloadCollectionView = true
            }
            
        }
        else if type == .move {
            print("moveItem@\(indexPath)")
            //blockOperations.append(BlockOperation(block: { [weak self] in
            //  if let this = self {
            //    DispatchQueue.main.async {
            self.photoCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
            // }
            //}
            
            //}))
        }
        else if type == .update {
            print("updateItem@\(indexPath)")
            //blockOperations.append(BlockOperation(block: { [weak self] in
            //  if let this = self {
            //    DispatchQueue.main.async {
            self.photoCollectionView.reloadItems(at: [indexPath!])
            //}
            //}
            
            //}))
        }
        else if type == .delete {
            print("deleteItem@\(indexPath)")
            if photoCollectionView.numberOfItems(inSection: (indexPath?.section)!) == 1 {
                self.shouldReloadCollectionView = true
            }else {
                if deleteAllBool == true {
                    blockOperations.append(BlockOperation(block: { [weak self] in
                        if let this = self {
                            //DispatchQueue.main.async {
                            this.photoCollectionView.deleteItems(at: [indexPath!])
                            //}
                        }
                    }))
                }else {
                    self.photoCollectionView.deleteItems(at: [indexPath!])
                    
                }
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == .insert {
            //blockOperations.append(BlockOperation(block: { [weak self] in
            // if let this = self {
            //   DispatchQueue.main.async {
            self.photoCollectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
            // }
            //}
            //}))
        }
        else if type == .update {
            //            blockOperations.append(BlockOperation(block: { [weak self] in
            //                if let this  = self {
            //                    DispatchQueue.main.async {
            self.photoCollectionView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
            //                    }
            //                }
            //            }))
        }
        else if type == .delete {
            //            blockOperations.append(BlockOperation(block: { [weak self] in
            //                if let this = self {
            //DispatchQueue.main.async {
            self.photoCollectionView.deleteSections(NSIndexSet(index: sectionIndex)as IndexSet)
            //}
            //                }
            //            }))
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if self.shouldReloadCollectionView == true {
            //DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
            //}
        }else {
            self.photoCollectionView.performBatchUpdates({ () -> Void in
                for operation: BlockOperation in self.blockOperations {
                    operation.start()
                }
            }, completion: {(finished) -> Void in
                self.blockOperations.removeAll(keepingCapacity: false)
                if self.photoCollectionView.numberOfItems(inSection: 0) < 1 {
                    FlickrClient.sharedInstance().getPhotosFromFlickr(lat: Float(self.mapView.annotations[0].coordinate.latitude), lon: Float(self.mapView.annotations[0].coordinate.longitude)) { (success, error) in
                        if success != true {
                            print(error)
                        }else {
                            //try! self.fetchedResultsController?.performFetch()
                            //self.photoCollectionView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (fetchedResultsController?.sections?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = fetchedResultsController?.sections![section]
        return (sectionData?.numberOfObjects)!
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
        cell.photoActivityIndicator.hidesWhenStopped = true
        cell.photoImageView.image = #imageLiteral(resourceName: "placeholder")
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        if photo.imageData != nil {
            cell.photoImageView.image = UIImage(data: photo.imageData! as Data)
            cell.photoActivityIndicator.stopAnimating()
            
        }else {
            let session = URLSession.shared
            let request = URLRequest(url: URL(string: photo.imageURL!)!)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error)
                }else {
                    photo.imageData = data! as NSData
                    cell.photoImageView.image = UIImage(data: photo.imageData! as Data)
                    cell.photoActivityIndicator.stopAnimating()
                }
            }
            task.resume()
        }
        return cell
    }
}
