//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Raman Liulkovich on 9/11/17.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

}

enum PhotoError: Error {
    case impossibleSavePhotos
}

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
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
    
}

extension Photo {
    
    static func photos(json: [String: Any], token: String) throws {
        
        let coreDataContext = CoreDataManager(modelName: "Instagram")
        
        guard let data = json["data"] as? [[String: Any]] else {
            throw PhotoError.impossibleSavePhotos
        }
        
        do {
            let context = coreDataContext.managedObjectContext
            for photo in data {
                
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
                
                let tempPhoto = Photo(context: context)

                tempPhoto.commentsCount = commentsCount
                tempPhoto.likesCount = likesCount
                tempPhoto.createdTime = date
                tempPhoto.id = id
                tempPhoto.imageLink = imageURL
                tempPhoto.userToken = token
                
                try context.save()
            }
            
        } catch {
            print(error)
        }        
    }
    
}
