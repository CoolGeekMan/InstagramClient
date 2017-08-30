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
    
    internal init(token: String, fullName: String, id: String, profilePictureURL: String, userName: String, followedBy: Int, follows: Int, media: Int) {
        self.token = token
        self.fullName = fullName
        self.id = id
        self.profilePictureURL = profilePictureURL
        self.userName = userName
        self.followedBy = followedBy
        self.follows = follows
        self.media = media
    }
}
