//
//  CoreDataStack.swift
//  Movie-DB
//
//  Created by Vidhyadharan on 23/12/20.
//

import Foundation
import CoreData

enum StorageType {
  case persistent, inMemory
}

class CoreDataStack {
    
    static private(set) var sharedInstance = CoreDataStack()
    
    static func inMemoryCoreDataStack() -> CoreDataStack {
        return CoreDataStack(storageType: .inMemory)
    }
    
    // MARK: - Core Data stack

    private var persistentContainer: NSPersistentContainer!
    
    private(set) lazy var viewContext: NSManagedObjectContext = {
        let viewContext = persistentContainer.viewContext
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
        
        return viewContext
    }()
    
    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return backgroundContext
    }()
    
    private init(storageType: StorageType = .persistent) {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Movie_DB")
            
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
            
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                     
                /*
                    Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        print(container.persistentStoreCoordinator.persistentStores.first?.url as Any)
        self.persistentContainer = container
    }
    
    // MARK: - Core Data Saving support

    func saveContext() throws {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                throw error
            }
        }
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw error
            }
        }
    }
}
