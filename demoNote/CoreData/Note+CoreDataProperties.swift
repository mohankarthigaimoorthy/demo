//
//  Note+CoreDataProperties.swift
//  demoNote
//
//  Created by Imcrinox Mac on 29/12/1444 AH.
//
//

import Foundation
import CoreData
import UIKit


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var priorityColor: UIColor?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var noteText: String?

}

extension Note : Identifiable {

}
