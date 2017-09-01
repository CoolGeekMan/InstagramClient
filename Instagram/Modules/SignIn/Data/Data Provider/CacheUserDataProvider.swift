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
    private let coreDataContext = CoreDataManager(modelName: "Instagram")
    
    internal func user(id: String) -> User? {
        var tempUser: User? = nil
        do {
            let context = coreDataContext.managedObjectContext
            
            let fetchRequest = NSFetchRequest<CacheUser>(entityName: "CacheUser")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let result = try context.fetch(fetchRequest)
            guard result.count > 0 else { return nil }
            guard let token = result[0].token,
                let fullName = result[0].fullName,
                let id = result[0].id,
                let userName = result[0].userName else { return nil }
            
            guard let image = result[0].profilePicture as Data? else { return nil }
            guard let profilePicture = UIImage.init(data: image) else { return nil }
            
            tempUser = User(token: token, fullName: fullName, id: id, profilePictureURL: "", userName: userName, followedBy: Int(result[0].followedBy), follows: Int(result[0].follows), media: Int(result[0].media))
            tempUser?.profilePicture = profilePicture
        } catch {
            print(error)
        }
        return tempUser
    }
    
    internal func users() -> [User] {
        var tempUsers = [User]()
        do {
            let context = coreDataContext.managedObjectContext
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            
            for user in result {
                guard let token = user.token,
                    let fullName = user.fullName,
                    let id = user.id,
                    let userName = user.userName else { return tempUsers }
                
                guard let image = user.profilePicture as Data? else { return tempUsers }
                guard let profilePicture = UIImage.init(data: image) else { return tempUsers }
                
                let tempUser = User(token: token, fullName: fullName, id: id, profilePictureURL: "", userName: userName, followedBy: Int(user.followedBy), follows: Int(user.follows), media: Int(user.media))
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
            let context = coreDataContext.managedObjectContext
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
            print("Error info: \(error)")
        }
    }

    internal func userCount() -> Int {
        var count = 0
        do {
            let context = coreDataContext.managedObjectContext
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            count = result.count
        } catch {
            print(error)
        }
        return count
    }
    
    func removeUserAlbums() {
        do {
            let context = coreDataContext.managedObjectContext
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            let userAlbums = result
            for album in userAlbums {
                context.delete(album)
            }
        } catch {
            print(error)
        }
    }
    
    

}
