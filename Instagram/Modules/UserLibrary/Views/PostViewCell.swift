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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
