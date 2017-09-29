//
//  CacheCommentDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/14/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import CoreData

class CacheCommentDataProvider {
    
    fileprivate let coreDataManager = CoreDataManager.shared
    
    func saveComments(json: [String: Any], id: String) throws {
        do {
            let context = try coreDataManager.managedObjectContext()
            
            guard let data = json["data"] as? [[String: Any]] else {
                throw PhotoError.impossibleGetPhotos
            }
            
            for comment in data {
                _ = try Comment.comment(comment: comment, mediaID: id, context: context)
                try context.save()
            }
        } catch {
            print(error)
        }
    }
    
    internal func haveComments(mediaID: String) -> Bool {
        var result = false
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
            fetchRequest.predicate = NSPredicate(format: "mediaID == %@", mediaID)
            let comments = try context.fetch(fetchRequest)
            result = comments.count > 0 ? true : false
        } catch {
            print(error)
        }
        return result
    }
    
    internal func comments(mediaID: String) -> [Comment] {
        var tempComments = [Comment]()
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
            fetchRequest.predicate = NSPredicate(format: "mediaID == %@", mediaID)
            let result = try context.fetch(fetchRequest)
            tempComments = result
        } catch {
            print(error)
        }
        return tempComments
    }
    
    internal func savePhoto(id: String, data: NSData) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let comments = try context.fetch(fetchRequest)
            guard comments.count > 0 else {
                return
            }
            comments[0].image = data
            try context.save()
        } catch {
            print(error)
        }
    }
    
    internal func removeComments(id: String) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
            fetchRequest.predicate = NSPredicate(format: "mediaID == %@", id)
            let result = try context.fetch(fetchRequest)
            for temp in result {
                context.delete(temp)
            }
            try context.save()
        } catch {
            print(error)
        }
    }
}
