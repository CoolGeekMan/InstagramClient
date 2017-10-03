//
//  SignInViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class SignInViewModel {

    private let authorizationProvider = AuthorizationProvider()
    internal let dataParser = SignInDataParser()
    private var user: User?
    internal let redirectHOST: String = Global.RequestURL.redirectHOST
    
    internal func authorizationRequest() -> URLRequest? {
        guard let url = authorizationProvider.authorizationURL() else {
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }
    
    internal func userData(token: String, completion: @escaping () -> ()) {
        authorizationProvider.userInfo(token: token) {[weak self] (user) in
            guard let tempUser = user else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            strongSelf.user = tempUser
            completion()
        }
    }
    
    internal func userImage(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        authorizationProvider.image(url: tempUser.profilePictureURL) {[weak self] (image) in
            guard let tempImage = image else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            strongSelf.user?.profilePicture = tempImage
            completion()
        }
    }
    
    internal func saveUser() {
        guard let temp = user else {
            return
        }
        authorizationProvider.saveCacheUser(user: temp)
    }
    
    internal func saveUserID(id: String) {
        authorizationProvider.saveUserID(id: id)
    }
    
    internal func userID() -> String? {
        guard let tempUser = user else {
            return nil
        }
        return tempUser.id
    }
}
