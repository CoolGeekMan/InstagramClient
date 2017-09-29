//
//  Comment+CoreDataClass.swift
//  
//
//  Created by Raman Liulkovich on 9/13/17.
//
//

import Foundation
import UIKit
import CoreData

enum CommentError: Error {
    case impossibleSaveComments
}

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
    public var photoImage: UIImage? {
        get {
            guard let data = image else {
                return nil
            }
            return UIImage(data: data as Data)
        }
    }

}

extension Comment {
    
    static func comment(comment: [String: Any], mediaID: String, context: NSManagedObjectContext) throws -> Comment {
        let tempComment = Comment(context: context)
        
        guard let id = comment["id"] as? String,
            let text = comment["text"] as? String,
            let createdTime = comment["created_time"] as? String,
            let doubleTime = Double(createdTime) else {
                throw CommentError.impossibleSaveComments
            }
                
        let date = NSDate(timeIntervalSince1970: doubleTime)
        
        guard let from = comment["from"] as? [String: Any],
            let userName = from["username"] as? String,
            let userPhoto = from["profile_picture"] as? String,
            let userID = from["id"] as? String,
            let fullName = from["full_name"] as? String else {
                throw CommentError.impossibleSaveComments
        }
        
        tempComment.createdTime = date
        tempComment.id = id
        tempComment.text = text
        tempComment.username = userName
        tempComment.userID = userID
        tempComment.imageLink = userPhoto
        tempComment.fullName = fullName
        tempComment.mediaID = mediaID
        
        return tempComment
    }    
}
