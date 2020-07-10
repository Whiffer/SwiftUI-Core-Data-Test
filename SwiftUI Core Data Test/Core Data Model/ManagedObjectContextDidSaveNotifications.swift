//
//  ManagedObjectContextDidSaveNotifications.swift
//  My Containers MacOS
//
//  Created by Chuck Hartman on 9/19/16.
//  Copyright © 2016 ForeTheGreen. All rights reserved.
//

import Foundation

// Sent each time the Core Data's Managed Object Context has been saved.

class ManagedObjectContextDidSaveNotifications
{
    fileprivate var observer: Any? = nil

    func addObserver(_ block: @escaping (Notification) -> Void)
    {
        if self.observer == nil {
            self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                                                   object: CoreData.stack.context,
                                                                   queue: nil,
                                                                   using: block)
         }
    }
    
    func removeObserver()
    {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}
