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
    
    internal func user(index: Int) -> User? {
        var tempUser: User? = nil
        do {
            let context = coreDataContext.managedObjectContext
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: "CacheUser"))
            guard result.count > index else { return nil }
            guard let token = result[index].token,
                let fullName = result[index].fullName,
                let id = result[index].id,
                let userName = result[index].userName else { return nil }
            
            guard let image = result[0].profilePicture as Data? else { return nil }
            guard let profilePicture = UIImage.init(data: image) else { return nil }
            
            tempUser = User(token: token, fullName: fullName, id: id, profilePictureURL: "", userName: userName, followedBy: Int(result[index].followedBy), follows: Int(result[index].follows), media: Int(result[index].media))
            tempUser?.profilePicture = profilePicture
        } catch {
            print(error)
        }
        return tempUser
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

    
}
