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
    private var user: User?
    
    internal func changeButton() -> String {
        return Constant.ActionSheet.changeButton
    }
    
    internal func addButton() -> String {
        return Constant.ActionSheet.addButton
    }
    
    internal func cancelButton() -> String {
        return Constant.ActionSheet.cancelButton
    }
    
    internal func fetchUser() {
        guard let id = startViewDataProvider.userID() else { return }
        user = dataProvider.user(id: id)
    }
    
    internal func userName() -> String? {
        guard let tempUser = user else { return nil }
        return tempUser.userName
    }
    
    internal func getUser() -> User? { //Я не знаю как назвать без get)
        return user
    }
    
    internal func users() -> [User] {
        let tempUsers = dataProvider.users()
        return tempUsers
    }
    
    internal func saveUserID(id: String) {
        startViewDataProvider.saveUserID(id: id)
    }
}
