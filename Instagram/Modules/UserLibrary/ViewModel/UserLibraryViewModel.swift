//
//  UserLibraryViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/31/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class UserLibraryViewModel {
    
    private struct Constant {
        internal struct ActionSheet {
            internal static let changeButton = "Change user"
            internal static let addButton = "Add user"
            internal static let cancelButton = "Cancel"
        }
    }
    
    private let startViewDataProvider = StartViewDataProvider()
    fileprivate let dataProvider = CacheUserDataProvider()
    internal var user: User?
    internal var availableUsers = [User]()
    
    
    internal let changeButton: String = {
       return Constant.ActionSheet.changeButton
    }()
    
    internal let addButton: String = {
        return Constant.ActionSheet.addButton
    }()
    
    internal let cancelButton: String = {
        return Constant.ActionSheet.cancelButton
    }()
        
    internal func fetchUser() {
        guard let id = startViewDataProvider.userID() else { return }
        do {
            user = try dataProvider.user(id: id)
        } catch {
            print(error)
        }
    }
    
    internal func userName() -> String? {
        guard let tempUser = user else { return nil }
        return tempUser.userName
    }
    
    internal func fetchAvailableUsers() {
        do {
            availableUsers = try dataProvider.users()
        } catch {
            print(error)
        }
    }
    
    internal func saveUserID(id: String) {
        startViewDataProvider.saveUserID(id: id)
    }
}
