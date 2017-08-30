//
//  CacheUser+CoreDataProperties.swift
//  
//
//  Created by Raman Liulkovich on 8/30/17.
//
//

import Foundation
import CoreData


extension CacheUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CacheUser> {
        return NSFetchRequest<CacheUser>(entityName: "CacheUser")
    }

    @NSManaged public var token: String?
    @NSManaged public var fullName: String?
    @NSManaged public var id: String?
    @NSManaged public var profilePicture: NSData?
    @NSManaged public var userName: String?
    @NSManaged public var followedBy: Int32
    @NSManaged public var follows: Int32
    @NSManaged public var media: Int32

}
