//
//  Photo+CoreDataClass.swift
//  VirtualTourist(CoreData)
//
//  Created by Zach Eidenberger on 10/13/17.
//  Copyright © 2017 ZacharyG. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    convenience init(id: Double, title: String, pin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = id
            self.title = title
            self.pin = pin
        }else {
            self.init(context: context)
        }
    }

}
