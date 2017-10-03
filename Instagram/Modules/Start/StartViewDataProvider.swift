//
//  StartViewDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/31/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

enum UserLogin: Error {
    case impossibleGettingSavesUserID
}

class StartViewDataProvider {
    
    internal func saveUserID(id: String) {
        UserDefaults.standard.set(id, forKey: Global.UserSaves.userID)
    }
    
    internal func userID() throws -> String {
        guard let id = UserDefaults.standard.value(forKey: Global.UserSaves.userID) as? String else {
            throw UserLogin.impossibleGettingSavesUserID
        }
        return id
    }
}
