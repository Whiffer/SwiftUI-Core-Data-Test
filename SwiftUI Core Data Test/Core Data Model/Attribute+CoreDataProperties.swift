//
//  Attribute+CoreDataProperties.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/19/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//
//

import Foundation
import CoreData


extension Attribute {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attribute> {
        return NSFetchRequest<Attribute>(entityName: "Attribute")
    }
    
    @NSManaged public var name: String
    @NSManaged public var order: Int32
    @NSManaged public var item: Item
    
}
