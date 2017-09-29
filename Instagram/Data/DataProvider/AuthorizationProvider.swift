//
//  AuthorizationProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/20/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import CoreData

enum CacheUserError: Error {
    case impossibleGettingUser
    case impossibleGettingUsers
    case impossibleCreateUser
}

class AuthorizationProvider {
    
    fileprivate let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Save and getting user in UserDefaults
    
    internal func saveUserID(id: String) {
        UserDefaults.standard.set(id, forKey: Global.UserSaves.userID)
    }
    
    internal func userID() throws -> String {
        guard let id = UserDefaults.standard.value(forKey: Global.UserSaves.userID) as? String else {
            throw UserLogin.impossibleGettingSavesUserID
        }
        return id
    }

    // MARK: - Getting user info through API
    
    internal func authorizationURL() -> URL? {
        let stringURL = "\(Global.RequestURL.authorizationURL)?\(Global.RequestParameter.clientID)=\(Global.RequestValue.clientID)&\(Global.RequestParameter.redirectURL)=\(Global.RequestValue.redirectURL)&\(Global.RequestParameter.responseType)=\(Global.RequestValue.responseType)&\(Global.RequestParameter.scope)=\(Global.RequestValue.scope)"
        guard let url = URL(string: stringURL) else {
            return nil
        }
        return url
    }
    
    internal func userInfo(token: String, result: @escaping (User?) -> ()) {
        let url = "\(Global.RequestURL.userInfoURL)?\(Global.RequestParameter.accessToken)=\(token)"
        
        Alamofire.request(url).responseJSON { (temp) in
            guard let json = temp.result.value as? [String: Any] else {
                return
            }
            do {
                let user = try User(json: json, token: token)
                result(user)
            } catch {
                print(error)
            }
        }
    }
    
    internal func image(url: String, result: @escaping (UIImage?) -> ()) {
        Alamofire.request(url).responseData { (response) in
            guard let data = response.data else {
                return
            }
            guard let picture = UIImage(data: data) else {
                return
            }
            result(picture)
        }
    }
    
    // MARK: - Getting and save user from CoreData
    
    internal func user(id: String) throws -> User {
        var tempUser: User? = nil
        do {
            let context = try coreDataManager.managedObjectContext()
            
            let fetchRequest = NSFetchRequest<CacheUser>(entityName: String(describing: CacheUser.self))
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
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: String(describing: CacheUser.self)))
            
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
            let result = try context.fetch(NSFetchRequest<CacheUser>(entityName: String(describing: CacheUser.self)))
            count = result.count
        } catch {
            print(error)
        }
        return count
    }
    
    internal func removeUser(id: String) {
        do {
            let context = try coreDataManager.managedObjectContext()
            let fetchRequest = NSFetchRequest<CacheUser>(entityName: String(describing: CacheUser.self))
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
