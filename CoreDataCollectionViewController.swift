////
////  CoreDataCollectionViewController.swift
////  VirtualTourist(CoreData)
////
////  Created by Zach Eidenberger on 10/19/17.
////  Copyright © 2017 ZacharyG. All rights reserved.
//
//import UIKit
//import CoreData
//
//class CoreDataCollectionViewController: UICollectionViewController{
//    //@IBOutlet weak var collectionView: UICollectionView!
//    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
//        didSet{
//            fetchedResultsController?.delegate = self
//            fetchResults()
//            collectionView.reloadData()
//        }
//    }
//    func fetchResults() {
//       if let fc = fetchedResultsController {
//            do {
//                try fc.performFetch()
//            }catch {
//                print(error)
//        }
//        }
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//}
//extension CoreDataCollectionViewController {
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = photoCollectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.photoActivityIndicator.isHidden = false
//        cell.photoActivityIndicator.startAnimating()
//        print(photosArray.count)
//        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
//        let photoURL = photo.imageURL
//        let session = URLSession.shared
//        let request = URLRequest(url: URL(string: photoURL!)!)
//        let task = session.dataTask(with: request) { (data, response, error) in
//            if error != nil {
//                print(error)
//            }else {
//                let imageData = data
//                cell.photoImageView?.image = UIImage(data: imageData!)
//                cell.photoActivityIndicator.isHidden = true
//                cell.photoActivityIndicator.stopAnimating()
//            }
//        }
//        task.resume()
//        return cell
//    }
//}
