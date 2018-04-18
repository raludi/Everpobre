//
//  Note+CoreDataProperties.swift
//  Everpobre
//
//  Created by Rafael Lujan on 12/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var images: NSSet?
    @NSManaged public var notebook: NoteBook?

}

// MARK: Generated accessors for images
extension Note {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: PhotoContainer)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: PhotoContainer)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
