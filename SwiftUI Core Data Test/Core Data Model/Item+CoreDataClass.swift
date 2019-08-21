//
//  Item+CoreDataClass.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 8/19/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject, Identifiable {

    //MARK: Helpers
    
    class func count() -> Int {
        
        let context = CoreData.stack.context
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    class func nextOrder() -> Int {
        
        let keyPathExpression = NSExpression.init(forKeyPath: "order")
        let maxNumberExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxNumber"
        expressionDescription.expression = maxNumberExpression
        expressionDescription.expressionResultType = .decimalAttributeType
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(expressionDescription)
        
        // Build out our fetch request the usual way
        let request: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        request.predicate = nil
        
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
    
    class func allInOrder() -> [Item] {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.predicate = nil
        
        do {
            let objects = try CoreData.stack.context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [Item]()
        }
    }
    
    class func allSelectedItems() -> [Item] {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.predicate = NSPredicate(format:"selected = true")
        
        do {
            let objects = try CoreData.stack.context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [Item]()
        }
    }
    
    //MARK: CRUD
    
    class func newItem() -> Item {
        
        return Item(context: CoreData.stack.context)
    }
    
    class func createItem(name: String, order: Int?) -> Item {
        
        let newItem = Item.newItem()
        newItem.name = name
        newItem.order = Int32(order ?? 0)
        CoreData.stack.save()
        
        return newItem
    }
    
    public func update(name: String, order: String) {
        
        self.name = name
        self.order = Int32(order)!
        CoreData.stack.save()
    }
    
    public func update(selected: Bool) {
        
        self.selected = selected
        CoreData.stack.save()
    }
    
    public func delete() {
        
        CoreData.stack.context.delete(self)
    }
    
}
