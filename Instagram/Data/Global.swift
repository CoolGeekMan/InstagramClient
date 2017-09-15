//
//  Global.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/29/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

internal struct Global {
    internal struct RequestParameter {
        static let clientID = "client_id"
        static let redirectURL = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
        static let accessToken = "access_token"
    }
    
    internal struct RequestValue {
        static let clientID = "060030f3564040c49d9be3231c491ca9"
        static let redirectURL = "https://www.getpostman.com/oauth2/callback"
        static let responseType = "token"
        static let scope = "basic+public_content+follower_list+comments+relationships+likes"
    }
    
    internal struct RequestURL {
        static let authorizationURL = "https://api.instagram.com/oauth/authorize/"
        static let userInfoURL = "https://api.instagram.com/v1/users/self/"
        static let redirectHOST = "www.getpostman.com"
        static let userMediaURL = "https://api.instagram.com/v1/users/self/media/recent/"
        static let mediaURL = "https://api.instagram.com/v1/media/"
        static let comments = "/comments"
    }
    
    internal struct UserSaves {
        static let userID = "userID"
    }
}
