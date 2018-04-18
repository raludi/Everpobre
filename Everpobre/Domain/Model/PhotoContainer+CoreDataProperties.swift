//
//  PhotoContainer+CoreDataProperties.swift
//  Everpobre
//
//  Created by Rafael Lujan on 12/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoContainer> {
        return NSFetchRequest<PhotoContainer>(entityName: "PhotoContainer")
    }

    @NSManaged public var image: Data?
    @NSManaged public var locationX: Float
    @NSManaged public var locationY: Float
    @NSManaged public var note: Note?

}
