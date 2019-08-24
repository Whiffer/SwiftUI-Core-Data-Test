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
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            let count = try CoreData.stack.context.count(for: fetchRequest)
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
        
        let datasource = CoreDataDataSource<Item>()
        return datasource.fetch()
    }

    #if DEBUG
    class func preview() -> Item {
        
        let items = Item.allInOrder()
        if items.count > 0 {
            return items.first!
        } else {
            return Item.createItem(name: "Item Preview", order: 999)
        }
    }
    #endif
    
    class func allSelectedItems() -> [Item] {
        
        let predicate = NSPredicate(format:"selected = true")
        let datasource = CoreDataDataSource<Item>(predicate: predicate)
        return datasource.fetch()
    }
    
    //MARK: CRUD
    
    class func newItem() -> Item {
        
        return Item(context: CoreData.stack.context)
    }
    
    class func createItem(name: String, order: Int?) -> Item {
        
        let item = Item.newItem()
        item.name = name
        item.order = Int32(order ?? 0)
        CoreData.stack.save()
        
        return item
    }
    
    public func update(name: String, order: String) {
        
        self.name = name
        self.order = Int32(order)!
        CoreData.stack.save()
    }
    
    public func update(selected: Bool, commit: Bool) {
        
        self.selected = selected
        CoreData.stack.save()
    }
    
    public func delete() {
        
        CoreData.stack.context.delete(self)
    }
    
}
