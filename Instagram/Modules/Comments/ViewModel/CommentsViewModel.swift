//
//  CommentsViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/13/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class CommentsViewModel {
    
    private let commentDataProvider = CommentsDataProvider()
    private let startViewDataProvider = StartViewDataProvider()
    private let userDataProvider = CacheUserDataProvider()
    private let cacheCommentDataProvider = CacheCommentDataProvider()
    
    var mediaID: String!
    var comments = [Comment]()
    var user: User?
    
    internal func fetchUser() {
        guard let id = startViewDataProvider.userID() else { return }
        do {
            user = try userDataProvider.user(id: id)
        } catch {
            print(error)
        }
    }
    
    internal func comments(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        
        commentDataProvider.mediaComments(token: tempUser.token, mediaID: mediaID) { 
            completion()
        }
    }
    
    internal func haveComment() -> Bool {
        return cacheCommentDataProvider.haveComments(mediaID: mediaID)
    }
    
    internal func fetchComments() {
        comments = cacheCommentDataProvider.comments(mediaID: mediaID)
    }
    
    internal func saveImage(id: String, data: NSData) {
        cacheCommentDataProvider.savePhoto(id: id, data: data)
    }
    
    internal func downloadImage(link: String, result: @escaping (Data?) -> ()) {
        commentDataProvider.userImage(link: link) { (data) in
            result(data)
        }
    }
}
