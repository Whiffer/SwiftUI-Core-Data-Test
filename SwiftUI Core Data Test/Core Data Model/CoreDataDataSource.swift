//
//  CoreDataDataSource.swift
//  SwiftUI Core Data Test
//
//  Created by Chuck Hartman on 7/5/19.
//  Copyright © 2019 ForeTheGreen. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

class CoreDataDataSource<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    // MARK: Trivial publisher for our changes.
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    //MARK: - Initializers
    
    override init() {
        
        self.sortKey1 = "order"
        self.sortKey2 = nil
        self.sectionNameKeyPath = nil
        
        self.predicate = nil
        self.predicateKey = nil
        self.predicateObject = nil
        
        super.init()
    }
    
    init(sortKey1: String?,
         sortKey2: String?,
         sectionNameKeyPath: String?,
         predicate: NSPredicate?,
         predicateKey: String?) {
        
        self.sortKey1 = sortKey1
        self.sortKey2 = sortKey2
        self.sectionNameKeyPath = sectionNameKeyPath
        
        self.predicate = predicate
        self.predicateKey = predicateKey
        self.predicateObject = nil

        super.init()
    }
    
    //MARK: - Private Properties
    
    private var sortKey1: String?
    private var sortKey2: String?
    private var sectionNameKeyPath: String?
    
    private var predicate: NSPredicate?
    private var predicateKey: String?
    private var predicateObject: NSManagedObject?
    
    private lazy var frc: NSFetchedResultsController<T> = {
        
        return configureFetchedResultsController()
    }()
    
    // MARK: Private Methods
    
    private func configureFetchedResultsController() -> NSFetchedResultsController<T> {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchBatchSize = 0
        
        if let sortKey1 = sortKey1 {
            
            if let sortKey2 = sortKey2 {
                
                let sortDescriptor1 = NSSortDescriptor(key: sortKey1, ascending: true)
                let sortDescriptor2 = NSSortDescriptor(key: sortKey2, ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
            } else {
                
                let sortDescriptor = NSSortDescriptor(key: sortKey1, ascending: true)
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
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreData.stack.context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        frc.delegate = self
        
        return frc
    }

    // MARK: Public Properties
    
    public var fetchedObjects: [T] {
        
        return frc.fetchedObjects ?? []
    }

    public var allInOrder:[T] {
        
        self.performFetch()
        return self.fetchedObjects
    }
    
    // MARK: Public Methods
    
    public func performFetch() {
        
        do {
            self.objectWillChange.send()
            
            try self.frc.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    public func allInOrderRelated(to: NSManagedObject) -> [T] {
        
        self.predicateObject = to
        self.frc = configureFetchedResultsController()
        
        self.performFetch()
        return self.fetchedObjects
    }
    
    public func changeSort(key: String, ascending: Bool) {
        
        self.frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        self.performFetch()
    }

    // MARK: Support for sectionNameKeyPath
    
    public var sections: [NSFetchedResultsSectionInfo] {
        
        self.performFetch()
        return self.frc.sections!
    }
    
    public func objects(forSection: NSFetchedResultsSectionInfo) -> [T] {
        
        return forSection.objects as! [T]
    }
    
    // MARK: CoreDataDataSource + NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.objectWillChange.send()
    }

}
