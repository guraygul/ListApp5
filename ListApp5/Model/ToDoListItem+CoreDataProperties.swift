//
//  ToDoListItem+CoreDataProperties.swift
//  ListApp5
//
//  Created by Güray Gül on 31.12.2023.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var order: Int64

}

extension ToDoListItem : Identifiable {

}
