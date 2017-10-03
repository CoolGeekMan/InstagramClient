//
//  HeaderCell.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/25/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var media: UILabel!
    @IBOutlet weak var followedBy: UILabel!
    @IBOutlet weak var follows: UILabel!
    @IBOutlet weak var runBotButton: UIButton!
    
    func configure(user: User) {
        runBotButton.layer.borderWidth = 1.0
        runBotButton.layer.cornerRadius = 5
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        followedBy.text = "\(user.followedBy)"
        follows.text = "\(user.follows)"
        media.text = "\(user.media)"
        fullName.text = user.fullName
        profilePicture.image = user.profilePicture
    }
}
