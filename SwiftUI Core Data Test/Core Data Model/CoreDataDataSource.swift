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
    
    // MARK: Private methods
    
    private lazy var frc: NSFetchedResultsController<T> = {
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreData.stack.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
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
    
    var fetchedObjects:[T] {
        get {
            return self.frc.fetchedObjects ?? []
        }
    }
    
    public func changeSort(key: String, ascending: Bool) {
        
        self.frc.fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        self.performFetch()
    }

    // MARK: CoreDataDataSource + NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.objectWillChange.send()
    }

}
