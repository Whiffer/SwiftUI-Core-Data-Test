//
//  CoreDataDataSource.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 7/4/20.
//  Copyright © 2020 ForeTheGreen. All rights reserved.
//

import Combine
import CoreData

class CoreDataDataSource<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Trivial publisher for our changes.
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    //MARK: - Initializer
    
    init(sortKey1: String? = nil,
         sortKey2: String? = nil,
         sectionNameKeyPath: String? = nil,
         predicateKey: String? = nil,
         predicateObject: NSManagedObject? = nil,
         sortAscending1: Bool? = nil,
         sortAscending2: Bool? = nil,
         predicate: NSPredicate? = nil,
         entity: NSEntityDescription? = nil) {

        self.sortKey1 = sortKey1 ?? "order"
        self.sortKey2 = sortKey2
        self.sectionNameKeyPath = sectionNameKeyPath
        self.predicateKey = predicateKey
        self.predicateObject = predicateObject
        self.sortAscending1 = sortAscending1 ?? true
        self.sortAscending2 = sortAscending2 ?? true
        self.predicate = predicate
        self.entity = entity

        self.frc = NSFetchedResultsController<T>()
        
        super.init()
        
        self.contextDidSaveNotifications.addObserver(managedObjectContextDidSave)
    }
    
    //MARK: - Private Properties
    
    private var sortKey1: String = "order"
    private var sortKey2: String? = nil
    private var sectionNameKeyPath: String? = nil
    private var predicateKey: String? = nil
    private var predicateObject: NSManagedObject? = nil
    private var sortAscending1: Bool = true
    private var sortAscending2: Bool = true
    private var predicate: NSPredicate? = nil
    private var entity: NSEntityDescription? = nil

    private var frc: NSFetchedResultsController<T>
    
    private let contextDidSaveNotifications = ManagedObjectContextDidSaveNotifications()
    
    // MARK: Fetch Modifiers
    
    public func sortKey1(_ sortKey1: String?) -> CoreDataDataSource {
        
        self.sortKey1 = sortKey1 ?? "order"
        return self
    }
    
    public func sortKey2(_ sortKey2: String?) -> CoreDataDataSource {
        
        self.sortKey2 = sortKey2
        return self
    }
    
    public func sectionNameKeyPath(_ sectionNameKeyPath: String?) -> CoreDataDataSource {
        
        self.sectionNameKeyPath = sectionNameKeyPath
        return self
    }
    
    public func predicateKey(_ predicateKey: String?) -> CoreDataDataSource {
        
        self.predicateKey = predicateKey
        return self
    }
    
    public func predicateObject(_ predicateObject: NSManagedObject?) -> CoreDataDataSource {
        
        self.predicateObject = predicateObject
        return self
    }
    
    public func sortAscending1(_ sortAscending1: Bool?) -> CoreDataDataSource {
        
        self.sortAscending1 = sortAscending1 ?? true
        return self
    }
    
    public func sortAscending2(_ sortAscending2: Bool?) -> CoreDataDataSource {
        
        self.sortAscending2 = sortAscending2 ?? true
        return self
    }
    
    public func predicate(_ predicate: NSPredicate?) -> CoreDataDataSource {
        
        self.predicate = predicate
        return self
    }
    
    public func entity(_ entity: NSEntityDescription?) -> CoreDataDataSource {
        
        self.entity = entity
        return self
    }
    
    // MARK: Private Methods
    
    // Constructs a Fetch Request based on current query properties
    private func configureFetchRequest() -> NSFetchRequest<T> {
        
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchBatchSize = 0

        if let entity = self.entity {
            fetchRequest.entity = entity
        }

        if let sortKey2 = self.sortKey2 {
            let sortDescriptor1 = NSSortDescriptor(key: self.sortKey1, ascending: self.sortAscending1)
            let sortDescriptor2 = NSSortDescriptor(key: sortKey2, ascending: self.sortAscending2)
            fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        } else {
            let sortDescriptor = NSSortDescriptor(key: self.sortKey1, ascending: self.sortAscending1)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if let predicate = self.predicate {
            fetchRequest.predicate = predicate
        } else {
            if let predicateKey = self.predicateKey {
                if let predicateObject = self.predicateObject {
                    let predicateString = String(format: "%@%@", predicateKey, " == %@")
                    fetchRequest.predicate = NSPredicate(format: predicateString, predicateObject)
                } else {
                    let predicateString = String(format: "%@%@", predicateKey, " = $OBJ")
                    let predicate = NSPredicate(format: predicateString)
                    fetchRequest.predicate = predicate.withSubstitutionVariables(["OBJ": NSNull()])
                }
            } else {
                fetchRequest.predicate = nil
            }
        }
        
        return fetchRequest
    }
    
    // Constructs a Fetch Request and a FRC
    private func configureFetchedResultsController() -> NSFetchedResultsController<T> {
        
        let fetchRequest = self.configureFetchRequest()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreData.stack.context,
                                             sectionNameKeyPath: self.sectionNameKeyPath,
                                             cacheName: nil)
        frc.delegate = self
        
        return frc
    }
    
    // Constructs a FRC and performs the Fetch
    private func performFetch() {
        
        do {
            self.frc = self.configureFetchedResultsController()
            try self.frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: Public Properties
    
    // Accessor Property to access FRC fetched objects without Fetch
    public var fetchedObjects: [T] {
        
        return self.frc.fetchedObjects ?? []
    }
    
    // Property to perform Fetch and supply results as an array to ForEach
    public var objects:[T] {
        
        self.performFetch()
        return self.fetchedObjects
    }
    
    // MARK: Public Methods that don't use FRC
    
    // Fetches all NSManagedObjects directly into an array
    public func fetch() -> [T] {
        
        let fetchRequest = self.configureFetchRequest()
        do {
            let objects = try CoreData.stack.context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [T]()
        }
    }
    
    // Count all NSManagedObjects for current Fetch Request
    public var count: Int {
        
        let fetchRequest = self.configureFetchRequest()
        do {
            let count = try CoreData.stack.context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return 0
        }
    }
    
    // MARK: Support for List Editing
    
    // default 'move' method for single-section Lists
    public func move(from source: IndexSet, to destination: Int) {
        
        self.reorder(from: source, to: destination, within: self.fetchedObjects)
    }
    
    // 'delete' method for single-section Lists
    public func delete(from source: IndexSet) {
        
        CoreData.executeBlockAndCommit {
            for index in source {
                CoreData.stack.context.delete(self.fetchedObjects[index])
            }
        }
    }
    
    // MARK: Support for nested Lists with sectionNameKeyPath
    
    // Used to supply Data to a ForEach List's outer loop
    public var sections: [NSFetchedResultsSectionInfo] {
        
        self.performFetch()
        return self.frc.sections!
    }
    
    // Used to supply Data to a ForEach List's inner loop
    public func objects(inSection: NSFetchedResultsSectionInfo) -> [T] {
        
        return inSection.objects as! [T]
    }
    
    // 'move' method that adjusts for multi-section Lists
    public func move(from source: IndexSet, to destination: Int, inSection: NSFetchedResultsSectionInfo) {
        
        self.reorder(from: source, to: destination, within: self.objects(inSection: inSection))
    }
    
    // 'delete' method that adjusts for multi-section Lists
    public func delete(from source: IndexSet, inSection: NSFetchedResultsSectionInfo) {
        
        CoreData.executeBlockAndCommit {
            for index in source {
                CoreData.stack.context.delete(self.objects(inSection: inSection)[index])
            }
        }
    }
    
    // MARK: Reorder helper
    
    private func reorder(from source: IndexSet, to before: Int, within: [T] ) {
        
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
    
    // MARK: CoreDataDataSource + NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.objectWillChange.send()
//        print("In controllerWillChangeContent()")
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.objectWillChange.send()
//        print("In controller:didChange:at:for:newIndexPath:")

//        let object = anObject as! NSManagedObject
//        let name = object.value(forKey: "name")
//
//        var changeType: String
//
//        switch type {
//        case .insert:
//            changeType = "inserted"
//        case .delete:
//            changeType = "deleted"
//        case .move:
//            changeType = "moved"
//        case .update:
//            changeType = "updated"
//        default:
//            changeType = "unknown"
//        }
//        print("In controller:didChange:for: \(changeType) on: \(name ?? "nil")")
    }
    
    // MARK: - NSNotification
    
    private func managedObjectContextDidSave(_ aNotification: Notification) {
        
        // If the CoreDataDataSource is being used with a sectionNameKeyPath,
        // it will not publish the change if a "Sort 1" object changes.
        // This makes sure it updates the necessary Views.
        if self.sectionNameKeyPath != nil {
            self.objectWillChange.send()
//            print("In managedObjectContextDidSave()")
//            
//            let userInfoDictionary = aNotification.userInfo!
//            if let insertedObjects = userInfoDictionary[NSInsertedObjectsKey] as? Set<NSManagedObject> {
//                for obj in insertedObjects {
//                    let className = String(describing: type(of: obj))
//                    let objName = self.managedObjectName(object: obj)
//                    print("Insert: \(className) \(objName)")
//                }
//            }
//            if let updatedObjects = userInfoDictionary[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
//                for obj in updatedObjects {
//                    let className = String(describing: type(of: obj))
//                    let objName = self.managedObjectName(object: obj)
//                    print("Update: \(className) \(objName)")
//                }
//            }
//            if let deletedObjects = userInfoDictionary[NSDeletedObjectsKey] as? Set<NSManagedObject> {
//                for obj in deletedObjects {
//                    let className = String(describing: type(of: obj))
//                    let objName = self.managedObjectName(object: obj)
//                    print("Delete: \(className) \(objName)")
//                }
//            }
        }
    }
    
//    private func managedObjectName(object: NSManagedObject) -> String {
//        return object.value(forKey: "name") as? String ?? ""
//    }
    
}
