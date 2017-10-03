//
//  PostCell.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/26/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsCountButton: UIButton!
    internal var id: String!
    
    func configure(user: User, photo: Photo) {
        profilePicture.image = user.profilePicture
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        userName.text = user.userName
        date.text = createdTime(date: photo.createdTime as Date)
        likesCount.text = "\(photo.likesCount) likes"
        id = photo.id
        commentsCountButton.setTitle("View all \(photo.commentsCount) comments", for: .normal)
    }
    
    private func createdTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let stringTime = dateFormatter.string(from: date)
        return stringTime
    }

}
