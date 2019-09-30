//
//  CoreDataDataSource.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 7/5/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import Combine
import CoreData

class CoreDataDataSource<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Trivial publisher for our changes.
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    //MARK: - Initializers
    
    override init() {
        
        super.init()
        
        self.sortKey1 = "order"
        self.sortKey2 = nil
        self.sectionNameKeyPath = nil
        
        self.predicate = nil
        self.predicateKey = nil
        self.predicateObject = nil
    }
    
    init(sortKey1: String?,
         sortKey2: String?,
         sectionNameKeyPath: String?) {
        
        super.init()
        
        self.sortKey1 = sortKey1
        self.sortKey2 = sortKey2
        self.sectionNameKeyPath = sectionNameKeyPath
        
        self.predicate = nil
        self.predicateKey = nil
        self.predicateObject = nil
    }
    
    init(predicateKey: String?) {
        
        super.init()
        
        self.sortKey1 = "order"
        self.sortKey2 = nil
        self.sectionNameKeyPath = nil
        
        self.predicate = nil
        self.predicateKey = predicateKey
        self.predicateObject = nil
    }
    
    init(predicate: NSPredicate?) {
        
        super.init()
        
        self.sortKey1 = "order"
        self.sortKey2 = nil
        self.sectionNameKeyPath = nil
        
        self.predicate = predicate
        self.predicateKey = nil
        self.predicateObject = nil
    }
    
    init(sortKey1: String?,
         sortAscending1: Bool,
         sortKey2: String?,
         sortAscending2: Bool,
         sectionNameKeyPath: String?,
         predicate: NSPredicate?,
         predicateKey: String?) {
        
        super.init()
        
        self.sortKey1 = sortKey1
        self.sortAscending1 = sortAscending1
        self.sortKey2 = sortKey2
        self.sortAscending2 = sortAscending2
        self.sectionNameKeyPath = sectionNameKeyPath
        
        self.predicate = predicate
        self.predicateKey = predicateKey
        self.predicateObject = nil
    }
    
    //MARK: - Private Properties
    
    private var sortKey1: String?
    private var sortAscending1: Bool = true
    private var sortKey2: String?
    private var sortAscending2: Bool = true
    private var sectionNameKeyPath: String?
    
    private var predicate: NSPredicate?
    private var predicateKey: String?
    private var predicateObject: NSManagedObject?
    
    
    private lazy var fetchRequest: NSFetchRequest<T> = {
        
        return configureFetchRequest()
    }()
    
    private lazy var frc: NSFetchedResultsController<T> = {
        
        return configureFetchedResultsController()
    }()

    // MARK: Private Methods
    
    // (Re)configures the Fetch Request
    // Used by both fetch() and performFetch()
    private func configureFetchRequest() -> NSFetchRequest<T> {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchBatchSize = 0
        
        if let sortKey1 = sortKey1 {
            
            if let sortKey2 = sortKey2 {
                
                let sortDescriptor1 = NSSortDescriptor(key: sortKey1, ascending: self.sortAscending1)
                let sortDescriptor2 = NSSortDescriptor(key: sortKey2, ascending: self.sortAscending2)
                fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            } else {
                
                let sortDescriptor = NSSortDescriptor(key: sortKey1, ascending: self.sortAscending1)
                fetchRequest.sortDescriptors = [sortDescriptor]
            }
        }
        
        if let _ = predicate {
            fetchRequest.predicate = predicate
        } else {
            
            if let predicateKey = predicateKey {
                
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
    
    // (Re)configures the Fetched Results Controller
    private func configureFetchedResultsController() -> NSFetchedResultsController<T> {
        
        let frc = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: CoreData.stack.context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        frc.delegate = self
        
        return frc
    }
    
    // Performs the fetch when using the Fetched Results Controller
    private func performFetch() {
        
        do {
            try self.frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
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
    
    // MARK: Public Properties
    
    // Used to supply Data to a ForEach List
    // Must call loadDataSource() in View's .onAppear
    public var fetchedObjects: [T] {
        
        return frc.fetchedObjects ?? []
    }
    
    // Used to supply Data to a ForEach List
    // Don't call loadDataSource() in View's .onAppear - Array must not change
    public var allInOrder:[T] {
        
        self.performFetch()
        return self.fetchedObjects
    }
    
    // MARK: Public Methods
    
    // Used to Perform a fetch when NOT using the Fetched Results Controller
    // Fetches all NSManagedObjects directly into an array
    public func fetch() -> [T] {
        
        do {
            let objects = try CoreData.stack.context.fetch(self.fetchRequest)
            return objects
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            return [T]()
        }
    }
    
    // Usually called within the View's .onAppear block
    public func loadDataSource() {
        
        self.objectWillChange.send()
        self.performFetch()
    }
    
    // Used to supply Data to a ForEach List
    public func loadDataSource(relatedTo: NSManagedObject) -> [T] {
        
        self.predicateObject = relatedTo
        self.fetchRequest = configureFetchRequest()
        self.frc = configureFetchedResultsController()
        
        return self.allInOrder
    }
   
    // Used to supply Data to a ForEach List
    public func loadDataSource(predicate: NSPredicate?) -> [T] {
        
        self.predicate = predicate
        self.fetchRequest = configureFetchRequest()
        self.frc = configureFetchedResultsController()
        
        return self.allInOrder
    }
    
    // Changes the primary Sort key and re-loads the data source
    public func changeSort(key: String, ascending: Bool) {
        
        self.sortKey1 = key
        self.sortAscending1 = ascending
        self.fetchRequest = configureFetchRequest()
        self.frc = configureFetchedResultsController()
        
        self.loadDataSource()
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
                print("Deleting Index: \(index)")
                CoreData.stack.context.delete(self.fetchedObjects[index])
            }
        }
    }
    
    // MARK: Support for sectionNameKeyPath
    
    // Used to supply Data to a ForEach List's outer loop
    // No need to call loadDataSource() in View's .onAppear
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
    
    // MARK: CoreDataDataSource + NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("In controllerWillChangeContent()")
        self.objectWillChange.send()
    }
        
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let object = anObject as! NSManagedObject
        let name = object.value(forKey: "name")
        
        var changeType: String
        
        switch type {
        case .insert:
            changeType = "inserted"
        case .delete:
            changeType = "deleted"
        case .move:
            changeType = "moved"
        case .update:
            changeType = "updated"
        default:
            changeType = "unknown"
        }
        
        print("Controller \(changeType): \(name!)")
//        self.objectWillChange.send()
//        object.objectWillChange.send()
    }
    
}
