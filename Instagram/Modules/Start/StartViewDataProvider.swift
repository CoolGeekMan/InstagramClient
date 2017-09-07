//
//  StartViewDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/31/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class StartViewDataProvider {
    
    internal func saveUserID(id: String) {
        UserDefaults.standard.set(id, forKey: Global.UserSaves.userID)
    }
    
    internal func haveUser() -> Bool {
        guard (UserDefaults.standard.value(forKey: Global.UserSaves.userID) as? String) != nil else { return false }
        return true
    }
    
    internal func userID() -> String? {
        guard let id = UserDefaults.standard.value(forKey: Global.UserSaves.userID) as? String else { return nil }
        return id
    }
}
