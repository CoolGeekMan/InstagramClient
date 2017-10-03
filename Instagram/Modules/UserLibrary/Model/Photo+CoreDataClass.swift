//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Raman Liulkovich on 9/11/17.
//
//

import Foundation
import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

}

enum PhotoError: Error {
    case impossibleSavePhotos
    case impossibleGetPhotos
}

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: String(describing: Photo.self))
    }
    
    @NSManaged public var userToken: String?
    @NSManaged public var commentsCount: Int64
    @NSManaged public var likesCount: Int64
    @NSManaged public var createdTime: NSDate
    @NSManaged public var id: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var thumbnailLink: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageLink: String?
    
    public var photoImage: UIImage? {
        get {
            guard let data = image else {
                return nil
            }
            return UIImage(data: data as Data)
        }
    }
}

extension Photo {
    
    static func photo(photo: [String: Any], token: String, context: NSManagedObjectContext) throws -> Photo {
        let tempPhoto = Photo(context: context)

        guard let comments = photo["comments"] as? [String: Any],
            let commentsCount = comments["count"] as? Int64,
            let likes = photo["likes"] as? [String: Any],
            let likesCount = likes["count"] as? Int64,
            let id = photo["id"] as? String,
            let createdTime = photo["created_time"] as? String,
            let doubleTime = Double(createdTime) else {
                throw PhotoError.impossibleSavePhotos
        }
                
        let date = NSDate(timeIntervalSince1970: doubleTime)
                
        guard let images = photo["images"] as? [String: Any],
            let image = images["standard_resolution"] as? [String: Any],
            let imageURL = image["url"] as? String else {
                throw PhotoError.impossibleSavePhotos
        }
            
        tempPhoto.commentsCount = commentsCount
        tempPhoto.likesCount = likesCount
        tempPhoto.createdTime = date
        tempPhoto.id = id
        tempPhoto.imageLink = imageURL
        tempPhoto.userToken = token
        
        return tempPhoto
    }
    
}
