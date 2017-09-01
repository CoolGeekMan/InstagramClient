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
    
    fileprivate let viewModel = UserLibraryViewModel()
    private lazy var change: UIBarButtonItem = { return UIBarButtonItem(title: "Change", style: .done, target: self, action: #selector(actionSheet))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        viewModel.fetchUser()
        
        guard let userName = viewModel.userName() else { return }
        navigationItem.title = userName
        navigationItem.rightBarButtonItems = [change]
    }
    
    
    internal func actionSheet() {
        let alertMessage = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertMessage.addAction(UIAlertAction.init(title: viewModel.changeButton(), style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            let usersAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let users = strongSelf.viewModel.users()

            for tempUser in users {
                usersAlert.addAction(UIAlertAction(title: "\(tempUser.userName)", style: .default, handler: { (action) in
                    strongSelf.viewModel.saveUserID(id: tempUser.id)
                    let tabBarController = MenuTabBarController()
                    strongSelf.present(tabBarController, animated: false, completion: nil)
                }))
            }
            
            usersAlert.addAction(UIAlertAction(title: strongSelf.viewModel.cancelButton(), style: .default, handler: nil))
            strongSelf.present(usersAlert, animated: true, completion: nil)
        }))
        
        alertMessage.addAction(UIAlertAction.init(title: viewModel.addButton(), style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            let signInViewController = SignInViewController(nibName: String(describing: SignInViewController.self), bundle: nil)
            strongSelf.present(signInViewController, animated: false, completion: nil)
        }))

        alertMessage.addAction(UIAlertAction(title: viewModel.cancelButton(), style: .default, handler: nil))
        
        present(alertMessage, animated: true, completion: nil)
    }
}

extension UserLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tempUser = viewModel.getUser() else { return UITableViewCell() }
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
