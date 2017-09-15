//
//  Comment+CoreDataClass.swift
//  
//
//  Created by Raman Liulkovich on 9/13/17.
//
//

import Foundation
import CoreData

@objc(Comment)
public class Comment: NSManagedObject {

}

extension Comment {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }
    
    @NSManaged public var mediaID: String?
    @NSManaged public var createdTime: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var username: String?
    @NSManaged public var imageLink: String?
    @NSManaged public var image: NSData?
    @NSManaged public var userID: String?
    @NSManaged public var fullName: String?
    @NSManaged public var id: String?
    
}

extension Comment {
    
    static func comments(json: [String: Any], mediaID: String) throws {
        let coreDataContext = CoreDataManager(modelName: "Instagram")
        
        guard let data = json["data"] as? [[String: Any]] else {
            throw NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't get"])
        }
        
        do {
            let context = coreDataContext.managedObjectContext

            for comment in data {
                guard let id = comment["id"] as? String,
                    let text = comment["text"] as? String,
                    let createdTime = comment["created_time"] as? String,
                    let doubleTime = Double(createdTime) else {
                        throw NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't get"])
                }
                
                let date = NSDate(timeIntervalSince1970: doubleTime)
                
                guard let from = comment["from"] as? [String: Any],
                    let userName = from["username"] as? String,
                    let userPhoto = from["profile_picture"] as? String,
                    let userID = from["id"] as? String,
                    let fullName = from["full_name"] as? String else {
                        throw NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't get"])
                }
                
                let tempComment = Comment(context: context)

                tempComment.createdTime = date
                tempComment.id = id
                tempComment.text = text
                tempComment.username = userName
                tempComment.userID = userID
                tempComment.imageLink = userPhoto
                tempComment.fullName = fullName
                tempComment.mediaID = mediaID
                
                try context.save()
            }
            
        } catch {
            print(error)
        }
    }
    
}
