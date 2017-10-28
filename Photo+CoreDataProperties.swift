//
//  Photo+CoreDataProperties.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/28/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var id: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
