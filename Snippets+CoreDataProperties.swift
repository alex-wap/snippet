//
//  Snippets+CoreDataProperties.swift
//  snippet
//
//  Created by Elliot Young on 9/29/16.
//  Copyright © 2016 Elliot Young. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Snippets {

    @NSManaged var dateCreated: Date?
    @NSManaged var dateUpdated: Date?
    @NSManaged var snippetText: String?
    @NSManaged var snippetTitle: String?

}
