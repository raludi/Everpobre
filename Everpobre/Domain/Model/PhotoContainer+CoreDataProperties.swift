//
//  PhotoContainer+CoreDataProperties.swift
//  Everpobre
//
//  Created by Rafael Lujan on 1/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoContainer> {
        return NSFetchRequest<PhotoContainer>(entityName: "PhotoContainer")
    }

    @NSManaged public var image: String?
    @NSManaged public var note: Note?

}
