//
//  PostViewCell.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class PostViewCell: UITableViewCell {

    @IBOutlet internal weak var profilePicture: UIImageView!
    @IBOutlet internal weak var userName: UILabel!
    @IBOutlet internal weak var photo: UIImageView!
    @IBOutlet internal weak var date: UILabel!
    @IBOutlet internal weak var likesCount: UILabel!
    @IBOutlet internal weak var commentsCountButton: UIButton!
    internal var id: String!

}
