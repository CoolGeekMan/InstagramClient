//
//  CommentsViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/13/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class CommentsViewModel {
    
    private struct Constant {
        internal struct Cell {
            static let comment = "CommentViewCell"
        }
        internal struct Date {
            static let format = "dd.MM.yyyy HH:mm"
        }
    }
    
    internal let commentsTitle: String = {
        return Global.TabBarTitle.comment
    }()
    
    internal let commentCell: String = {
       return Constant.Cell.comment
    }()
    
    private let authorizationProvider = AuthorizationProvider()
    private let cacheDataProvider = CacheDataProvider()
    private let apiProvider = APIProvider()
    
    var mediaID: String!
    var comments = [Comment]()
    var user: User?
    
    internal func fetchUser() {
        do {
            let id = try authorizationProvider.userID()
            user = try authorizationProvider.user(id: id)
        } catch {
            print(error)
        }
    }
    
    internal func comments(completion: @escaping () -> ()) {
        guard let tempUser = user else {
            return
        }
        
        apiProvider.mediaComments(token: tempUser.token, mediaID: mediaID) { [weak self] (json) in
            do {
                guard let strongSelf = self else {
                    return
                }
                try strongSelf.cacheDataProvider.saveComments(json: json, id: strongSelf.mediaID)
                completion()
            } catch {
                print(error)
            }
        }
    }
    
    func timeText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.Date.format
        let stringTime = dateFormatter.string(from: date)
        return stringTime
    }
    
    internal func haveComment() -> Bool {
        return cacheDataProvider.haveComments(mediaID: mediaID)
    }
    
    internal func fetchComments() {
        comments = cacheDataProvider.comments(mediaID: mediaID)
    }
    
    internal func saveImage(id: String, data: NSData) {
        cacheDataProvider.savePhoto(id: id, data: data)
    }
    
    internal func downloadImage(link: String, result: @escaping (Data?) -> ()) {
        apiProvider.userImage(link: link) { (data) in
            result(data)
        }
    }
}
