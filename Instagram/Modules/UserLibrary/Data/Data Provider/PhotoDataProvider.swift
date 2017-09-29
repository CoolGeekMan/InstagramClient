//
//  PhotoDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/11/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import CoreData

class PhotoDataProvider {
    
    fileprivate let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func savePhotos(json: [String: Any], token: String) throws {
        do {
            let context = try coreDataManager.managedObjectContext()
            
            guard let data = json["data"] as? [[String: Any]] else {
                throw PhotoError.impossibleGetPhotos
            }
            
            for photo in data {
                _ = try Photo.photo(photo: photo, token: token, context: context)
                try context.save()
            }
        } catch {
            print(error)
        }
    }
    
    internal func photos(token: String) -> [Photo] {
        var tempPhotos = [Photo]()
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "userToken == %@", token)
            let sortDescriptor = NSSortDescriptor(key: "createdTime", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let result = try context.fetch(fetchRequest)
            
            tempPhotos = result
        } catch {
            print(error)
        }
        return tempPhotos
    }
    
    internal func havePhotos(token: String) -> Bool {
        var result = false
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "userToken == %@", token)
            let photos = try context.fetch(fetchRequest)
            result = photos.count > 0 ? true : false
        } catch {
            print(error)
        }
        return result
    }
    
    internal func addImage(id: String, data: NSData) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let result = try context.fetch(fetchRequest)
            result[0].image = data
            try context.save()
        } catch {
            print(error)
        }
    }
    
    internal func checkIamge(id: String) -> Bool {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let photos = try context.fetch(fetchRequest)

            guard photos.count > 0 else {
                return true
            }
            guard photos[0].image != nil else {
                return false
            }
        } catch {
            print(error)
        }
        return true
    }
    
    internal func removePhotos(token: String) -> [String] {
        var mediaIDs = [String]()
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
            fetchRequest.predicate = NSPredicate(format: "userToken == %@", token)
            let result = try context.fetch(fetchRequest)
            for temp in result {
                if let id = temp.id {
                    mediaIDs.append(id)
                }
                context.delete(temp)
            }
        } catch {
            print(error)
        }
        return mediaIDs
    }
}
