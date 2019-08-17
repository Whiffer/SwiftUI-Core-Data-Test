//
//  Entity+CoreDataClass.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 6/25/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine

@objc(Entity)
public class Entity: NSManagedObject, Identifiable {

    //MARK: Helpers
    
    class func count() -> Int {
        
        let context = CoreData.stack.context
        
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        
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
        let request: NSFetchRequest<NSFetchRequestResult> = Entity.fetchRequest()
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
                // If no entities present, return 0
                return 0
            }
        } catch _ {
            // If any failure, just return default
            return 0
        }
    }
    
    class func reorder(from source: IndexSet, to before: Int, within: [Entity] ) {
        
        let firstIndex = source.min()!
        let lastIndex = source.max()!
        
        let firstRowToReorder = (firstIndex < before) ? firstIndex : before
        let lastRowToReorder = (lastIndex > (before-1)) ? lastIndex : (before-1)
        
        if firstRowToReorder != lastRowToReorder {
            
            CoreData.executeBlockAndCommit {
                
                var newOrder = firstRowToReorder
                if newOrder < firstIndex {
                    // Moving dragged items up, so re-order dragged items first
                    
                    // Re-order dragged items
                    for index in source {
                        within[index].setValue(newOrder, forKey: "order")
                        newOrder = newOrder + 1
                    }
                    
                    // Re-order non-dragged items
                    for rowToMove in firstRowToReorder..<lastRowToReorder {
                        if !source.contains(rowToMove) {
                            within[rowToMove].setValue(newOrder, forKey: "order")
                            newOrder = newOrder + 1
                        }
                    }
                } else {
                    // Moving dragged items down, so re-order dragged items last
                    
                    // Re-order non-dragged items
                    for rowToMove in firstRowToReorder...lastRowToReorder {
                        if !source.contains(rowToMove) {
                            within[rowToMove].setValue(newOrder, forKey: "order")
                            newOrder = newOrder + 1
                        }
                    }
                    
                    // Re-order dragged items
                    for index in source {
                        within[index].setValue(newOrder, forKey: "order")
                        newOrder = newOrder + 1
                    }
                }
            }
        }
    }
    
    class func delete(from source: IndexSet, within: [Entity] ) {
        
        CoreData.executeBlockAndCommit {
            for index in source {
                within[index].delete()
            }
        }
    }
    
    class func allInOrder() -> [Entity] {
        
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.predicate = nil
        
        do {
            let objects = try CoreData.stack.context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [Entity]()
        }
    }
    
    class func allSelectedEntities() -> [Entity] {
        
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.predicate = NSPredicate(format:"selected = true")
        
        do {
            let objects = try CoreData.stack.context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [Entity]()
        }
    }
    
    //MARK: CRUD
    
    class func newEntity() -> Entity {
        
        return Entity(context: CoreData.stack.context)
    }
    
    class func createEntity(name: String, order: Int?) -> Void {
        
        let newEntity = Entity.newEntity()
        newEntity.name = name
        newEntity.order = Int32(order ?? 0)
        CoreData.stack.save()
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
