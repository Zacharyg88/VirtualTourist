//
//  photoCollectionViewCell.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/20/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//
import UIKit

class photoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoActivityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        photoImageView.image = nil
        super.prepareForReuse()
        
    }
}
