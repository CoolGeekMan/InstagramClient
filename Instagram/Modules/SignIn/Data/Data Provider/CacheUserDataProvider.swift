 //
//  CacheUserDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CacheUserDataProvider {
    fileprivate let coreDataManager = CoreDataManager.shared
    
    internal func user(id: String) throws -> User {
        var tempUser: User? = nil
        do {
            let context = try coreDataManager.managedObjectContext()
            
            let fetchRequest = NSFetchRequest<CacheUser>(entityName: "CacheUser")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let result = try context.fetch(fetchRequest)
            guard result.count > 0 else {
                throw CacheUserError.impossibleGettingUser
            }
            
            guard let image = result[0].profilePicture as Data? else {
                throw CacheUserError.impossibleGettingUser
            }
            guard let profilePicture = UIImage.init(data: image) else {
                throw CacheUserError.impossibleGettingUser
            }
            
            tempUser = try User(user: result[0])
            tempUser?.profilePicture = profilePicture
        } catch {
            print(error)
        }
        
        guard let user = tempUser else {
            throw CacheUserError.impossibleGettingUser
        }
        
        return user
    }
    
    internal func users() throws -> [User] {
        var tempUsers = [User]()
        do {
            let context = try coreDataManager.managedObjectContext()
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            
            for user in result {
                
                guard let image = user.profilePicture as Data? else {
                    throw CacheUserError.impossibleGettingUsers
                }
                guard let profilePicture = UIImage.init(data: image) else {
                    throw CacheUserError.impossibleGettingUsers
                }
                
                let tempUser = try User(user: user)
                tempUser.profilePicture = profilePicture
                tempUsers.append(tempUser)
            }
        } catch {
            print(error)
        }
        return tempUsers
    }
    
    internal func saveCacheUser(user: User) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let tempUserData = CacheUser(context: context)
        
            tempUserData.followedBy = Int32(user.followedBy)
            tempUserData.follows = Int32(user.follows)
            tempUserData.fullName = user.fullName
            tempUserData.id = user.id
            tempUserData.media = Int32(user.media)
            tempUserData.token = user.token
            tempUserData.userName = user.userName
            
            if let temp = UIImageJPEGRepresentation(user.profilePicture, 0.1) {
                tempUserData.profilePicture = temp as NSData
            }
            
            try context.save()
        } catch {
            print(error)
        }
    }

    internal func userCount() -> Int {
        var count = 0
        do {
            let context = try coreDataManager.managedObjectContext()
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            count = result.count
        } catch {
            print(error)
        }
        return count
    }
    
    internal func removeUser(id: String) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<CacheUser>(entityName: "CacheUser")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let result = try context.fetch(fetchRequest)
            for temp in result {
                context.delete(temp)
            }
        } catch {
            print(error)
        }
    }
    

}
