//
//  User.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class User {
    internal let token: String
    internal let fullName: String
    internal let id: String
    internal let profilePictureURL: String
    internal let userName: String
    internal let followedBy: Int
    internal let follows: Int
    internal let media: Int
    internal var profilePicture = #imageLiteral(resourceName: "defaultPicture")
    
    internal init(json: [String: Any], token: String) throws {
        guard let data = json["data"] as? [String: Any],
            let counts = data["counts"] as? [String: Any] else {
                throw CacheUserError.impossibleCreateUser
        }
        
        guard let fullName = data["full_name"] as? String,
            let id = data["id"] as? String,
            let profilePictureURL = data["profile_picture"] as? String,
            let userName = data["username"] as? String else {
                throw CacheUserError.impossibleCreateUser
        }
        
        guard let followedBy = counts["followed_by"] as? Int,
            let follows = counts["follows"] as? Int,
            let media = counts["media"] as? Int else {
                throw CacheUserError.impossibleCreateUser
        }
        
        self.token = token
        self.fullName = fullName
        self.id = id
        self.profilePictureURL = profilePictureURL
        self.userName = userName
        self.followedBy = followedBy
        self.follows = follows
        self.media = media
    }
    
    internal init(user: CacheUser) throws {
        guard let token = user.token,
            let fullName = user.fullName,
            let id = user.id,
            let userName = user.userName else {
                throw CacheUserError.impossibleGettingUser
        }
    
        self.token = token
        self.fullName = fullName
        self.id = id
        self.profilePictureURL = ""
        self.userName = userName
        self.followedBy = Int(user.followedBy)
        self.follows = Int(user.follows)
        self.media = Int(user.media)        
    }
    
}

