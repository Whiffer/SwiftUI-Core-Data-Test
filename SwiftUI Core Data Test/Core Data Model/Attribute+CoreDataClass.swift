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
    
    class func nextOrderFor(item: Item) -> Int {
        
        let keyPathExpression = NSExpression.init(forKeyPath: "order")
        let maxNumberExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxNumber"
        expressionDescription.expression = maxNumberExpression
        expressionDescription.expressionResultType = .decimalAttributeType
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(expressionDescription)
        
        let predicate = NSPredicate(format: "item == %@", item)

        // Build out our fetch request the usual way
        let request: NSFetchRequest<NSFetchRequestResult> = Attribute.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        request.predicate = predicate
        
        // Our result should to be an array of dictionaries.
        var results: [[String:AnyObject]]?
        
        do {
            results = try CoreData.stack.context.fetch(request) as? [[String:NSNumber]]
            
            if let maxNumber = results?.first!["maxNumber"]  {
                // Return one more than the current max order
                return maxNumber.intValue + 1
            } else {
                // If no items present, return 0
                return 0
            }
        } catch _ {
            // If any failure, just return default
            return 0
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
