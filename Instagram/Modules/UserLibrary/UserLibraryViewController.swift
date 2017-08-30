//
//  UserLibraryViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class UserLibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate let dataProvider = CacheUserDataProvider()

    var user: User?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        user = dataProvider.user(index: 0)
    }
}

extension UserLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tempUser = user else { return UITableViewCell() }
        guard let cell = Bundle.main.loadNibNamed("HeaderViewCell", owner: self, options: nil)?.first as? HeaderViewCell else { return UITableViewCell() }

        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.width / 2
        cell.followedBy.text = "\(tempUser.followedBy)"
        cell.follows.text = "\(tempUser.follows)"
        cell.media.text = "\(tempUser.media)"
        cell.fullName.text = tempUser.fullName
        cell.profilePicture.image = tempUser.profilePicture

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
