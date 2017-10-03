//
//  UserLibraryViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/31/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

enum DisplayStyle {
    case List
    case Box
}

protocol UserLibraryViewModelProtocol {
    
    var user: User? { get set }
    var availableUsers: [User] { get set }
    var photos: MutableProperty<[Photo]> { get set }
    
    func fetchUser()
    func userName() -> String?
    func fetchAvailableUsers()
    func saveUserID(id: String)
    func haveMedia() -> Bool
    func media(completion: @escaping () -> ())
    func fetchPhotos()
    func downloadPhoto(index: Int, completion: @escaping (Data) -> ())
    func cellCount(displayStyle: DisplayStyle) -> Int
    func photoId(index: Int) -> String?
    func reloadData(completion: @escaping () -> ())

}

class UserLibraryViewModel: UserLibraryViewModelProtocol {

    private let authorizationProvider = AuthorizationProvider()
    private let cacheDataProvider = CacheDataProvider()
    private let apiProvider = APIProvider()
    
    internal var user: User?
    internal var availableUsers = [User]()
    
    var photos: MutableProperty<[Photo]> = MutableProperty([])
    
    func fetchUser() {
        do {
            let id = try authorizationProvider.userID()
            user = try authorizationProvider.user(id: id)
        } catch {
            print(error)
        }
    }
    
    func userName() -> String? {
        guard let tempUser = user else {
            return nil
        }
        return tempUser.userName
    }
    
    func fetchAvailableUsers() {
        do {
            availableUsers = try authorizationProvider.users()
        } catch {
            print(error)
        }
    }
    
    func saveUserID(id: String) {
        authorizationProvider.saveUserID(id: id)
    }
    
    func haveMedia() -> Bool {
        guard let tempUser = user else {
            return false
        }
        return cacheDataProvider.havePhotos(token: tempUser.token)
    }
    
    func media(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        apiProvider.userMedia(token: tempUser.token) { [weak self] (json) in
            do {
                guard let strongSelf = self else {
                    return
                }
                try strongSelf.cacheDataProvider.savePhotos(json: json, token: tempUser.token)
                completion()
            } catch {
                print(error)
            }
        }
    }
    
    func fetchPhotos() {
        guard let tempUser = user else {
            return
        }
        photos.value = cacheDataProvider.photos(token: tempUser.token)
    }
    
    func downloadPhoto(index: Int, completion: @escaping (Data) -> ()) {
        guard let link = photos.value[index].imageLink, let id = photos.value[index].id else {
            return
        }
        
        apiProvider.photo(link: link) { (image) in
            self.cacheDataProvider.addImage(id: id, data: image)
            let data = image as Data
            completion(data)
        }
    }
    
    func cellCount(displayStyle: DisplayStyle) -> Int {
        var cellCount = photos.value.count
        
        switch displayStyle {
        case .List:
            cellCount += 2
        case .Box:
            break
        }
        
        return cellCount
    }
    
    func photoId(index: Int) -> String? {
        return photos.value[index].id
    }
    
    func removeOldData() {
        guard let tempUser = user else {
            return
        }
        let ids = cacheDataProvider.removePhotos(token: tempUser.token)
        for id in ids {
            cacheDataProvider.removeComments(id: id)
        }
    }
    
    func reloadData(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        authorizationProvider.userInfo(token: tempUser.token) {[weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            guard let gettingUser = result else {
                return
            }
            strongSelf.authorizationProvider.image(url: gettingUser.profilePictureURL, result: { (image) in
                guard let tempImage = image else {
                    return
                }
                strongSelf.authorizationProvider.removeUser(id: tempUser.id)
                gettingUser.profilePicture = tempImage
                strongSelf.authorizationProvider.saveUserID(id: gettingUser.id)
                strongSelf.authorizationProvider.saveCacheUser(user: gettingUser)
                completion()
            })
        }
    }
    
}
