//
//  CoreDataCollectionViewController.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/19/17.
//  Copyright © 2017 ZacharyG. All rights reserved.


//import UIKit
//import CoreData
//
//class CoreDataCollectionViewController: UICollectionViewController{
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    
//    
//    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
//        didSet{
//            fetchedResultsController?.delegate = self
//            fetchResults()
//            tableView.reloadData()
//            
//        }
//    }
//    
//    
//    func fetchResults() {
//       if let fc = fetchedResultsController {
//            do {
//                try fc.performFetch()
//            }catch {
//                print(error)
//        }
//        }
//    }
//}
