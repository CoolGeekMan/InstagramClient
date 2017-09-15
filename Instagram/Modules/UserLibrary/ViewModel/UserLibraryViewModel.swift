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

    private let dataProvider = CacheUserDataProvider()
    private let startViewDataProvider = StartViewDataProvider()
    private let userLibraryProvider = UserLibraryProvider()
    private let photoDataProvider = PhotoDataProvider()
    private let cacheCommentDataProvider = CacheCommentDataProvider()
    private let signInDataProvider = SignInProvider()
    private let cacheUserDataProvider = CacheUserDataProvider()
    private let startDataProvider = StartViewDataProvider()
    
    internal var user: User?
    internal var availableUsers = [User]()
    internal var photos = [Photo]()
    
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
    
    internal func haveMedia() -> Bool {
        return photoDataProvider.havePhotos(token: (user?.token)!)
    }
    
    internal func media(completion: @escaping () -> ()) {
        guard let tempUser = user else { return }
        userLibraryProvider.userMedia(token: tempUser.token) {
            completion()
        }
    }
    
    internal func fetchPhotos() {
        guard let tempUser = user else { return }
        photos = photoDataProvider.photos(token: tempUser.token)
    }
    
    internal func checkImage(index: Int) -> Bool {
        guard let id = photos[index].id else { return false }
        return photoDataProvider.checkIamge(id: id)
    }
    
    internal func downloadPhoto(index: Int, completion: @escaping (Data) -> ()) {
        guard let link = photos[index].imageLink, let id = photos[index].id else { return }
        
        userLibraryProvider.photo(link: link) { (image) in
            self.photoDataProvider.addImage(id: id, data: image)
            let data = image as Data
            completion(data)
        }
    }
    
    func cellCount() -> Int {
        return photos.count + 1
    }
    
    func removeOldData() {
        guard let tempUser = user else {
            return
        }
        let ids = photoDataProvider.removePhotos(token: tempUser.token)
        for id in ids {
            cacheCommentDataProvider.removeComments(id: id)
        }
    }
    
    func reloadData(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        signInDataProvider.userInfo(token: tempUser.token) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            guard let gettingUser = result else {
                return
            }
            strongSelf.signInDataProvider.image(url: gettingUser.profilePictureURL, result: { (image) in
                guard let tempImage = image else {
                    return
                }
                strongSelf.cacheUserDataProvider.removeUser(id: tempUser.id)
                gettingUser.profilePicture = tempImage
                strongSelf.startDataProvider.saveUserID(id: gettingUser.id)
                strongSelf.cacheUserDataProvider.saveCacheUser(user: gettingUser)
                completion()
            })
        }
    }
    
}
