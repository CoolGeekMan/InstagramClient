//
//  CoreDataManager.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private func managedObjectModel() throws -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                throw NSError(domain: "CoreDataStack", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't get managedObjectModel!"])
        }
        return managedObjectModel
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var persistentStoreCoordinator = NSPersistentStoreCoordinator()
        do {
            let managerModel = try self.managedObjectModel()
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managerModel)
            let fileManager = FileManager.default
            let storeName = "\(self.modelName).sqlite"
            
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                  configurationName: nil,
                                                                  at: persistentStoreURL,
                                                                  options: nil)
            return persistentStoreCoordinator

        } catch {
            print(error)
        }
        return persistentStoreCoordinator
    }()
}
