//
//  HeaderViewCell.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class HeaderViewCell: UITableViewCell {

    @IBOutlet internal weak var profilePicture: UIImageView!
    @IBOutlet internal weak var fullName: UILabel!
    @IBOutlet internal weak var media: UILabel!
    @IBOutlet internal weak var followedBy: UILabel!
    @IBOutlet internal weak var follows: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
