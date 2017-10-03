//
//  CoreDataManager.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataManagerError: Error {
    case impossibleGettingManagedObjectModel
    case impossibleCreatingPersistentStoreCoordinator
    case impossibleCreatingManagerObjectContext
}

class CoreDataManager {
    
    private struct Constant {
        internal struct Names {
            internal static let model = "Instagram"
            internal static let modelExtension = "momd"
            internal static let baseType = "sqlite"
        }
    }

    private let modelName: String
    private var memoryManagedObjectContext: NSManagedObjectContext?

    static let shared = CoreDataManager(modelName: Constant.Names.model)
    
    private init(modelName: String) {
        self.modelName = modelName
    }
    
    func managedObjectContext() throws -> NSManagedObjectContext {
        if let moc = memoryManagedObjectContext {
            return moc
        } else {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            do {
                managedObjectContext.persistentStoreCoordinator = try self.persistentStoreCoordinator()
            } catch {
                throw error
            }
            memoryManagedObjectContext = managedObjectContext
            return managedObjectContext
        }
    }
    
    private func managedObjectModel() throws -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: Constant.Names.modelExtension),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                throw CoreDataManagerError.impossibleGettingManagedObjectModel
        }
        return managedObjectModel
    }
    
    private func persistentStoreCoordinator() throws -> NSPersistentStoreCoordinator {
        var persistentStoreCoordinator = NSPersistentStoreCoordinator()
        do {
            let managerModel = try self.managedObjectModel()
            persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managerModel)
            let fileManager = FileManager.default
            let storeName = "\(self.modelName).\(Constant.Names.baseType)"
            
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)            
        } catch {
            throw CoreDataManagerError.impossibleCreatingPersistentStoreCoordinator
        }
        return persistentStoreCoordinator
    }
}
