//
//  Attribute+CoreDataClass.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/19/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Attribute)
public class Attribute: NSManagedObject, Identifiable {

    //MARK: Helpers
    
    class func count() -> Int {
        
        let context = CoreData.stack.context
        
        let fetchRequest: NSFetchRequest<Attribute> = Attribute.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    //MARK: CRUD
    
    class func newAttribute() -> Attribute {
        
        return Attribute(context: CoreData.stack.context)
    }
    
    class func createAttributeFor(item: Item, name: String, order: Int?) -> Void {
        
        let newAttribute = Attribute.newAttribute()
        newAttribute.name = name
        newAttribute.order = Int32(order ?? 0)
        newAttribute.item = item
        CoreData.stack.save()
    }
    
    public func update(name: String, order: String) {
        
        self.name = name
        self.order = Int32(order)!
        CoreData.stack.save()
    }
    
    public func delete() {
        
        CoreData.stack.context.delete(self)
    }
    
}
