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
    private lazy var change: UIBarButtonItem = {
        return UIBarButtonItem(title: "Change", style: .done, target: self, action: #selector(presentActionSheet))
    }()
    
    let alertMessage: UIAlertController = {
        let temp = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        viewModel.fetchUser()
        
        guard let userName = viewModel.userName() else { return }
        navigationItem.title = userName
        navigationItem.rightBarButtonItems = [change]

        settingActionSheet()
    }
    
    @objc private func presentActionSheet() {
        present(alertMessage, animated: true, completion: nil)
    }
    
    private func selectionUserAction(user: User) -> UIAlertAction {
        let temp = UIAlertAction(title: "\(user.userName)", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.saveUserID(id: user.id)
            let tabBarController = UITabBarController()
            let userViewController = UserLibraryViewController(nibName: String(describing: UserLibraryViewController.self), bundle: nil)
            let navigationController = UINavigationController(rootViewController: userViewController)
            navigationController.title = "User"
            tabBarController.viewControllers = [navigationController]
            strongSelf.present(tabBarController, animated: false, completion: nil)
        })
        return temp
    }
    
    private func changeAlertAction() -> UIAlertAction {
        let action = UIAlertAction.init(title: viewModel.changeButton, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.fetchAvailableUsers()
            let usersAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let users = strongSelf.viewModel.availableUsers
            
            for tempUser in users {
                usersAlert.addAction(strongSelf.selectionUserAction(user: tempUser))
            }
            
            usersAlert.addAction(strongSelf.cancelAlertAction())
            strongSelf.present(usersAlert, animated: true, completion: nil)
        })
        return action
    }
    
    private func addAlertAction() -> UIAlertAction {
        let temp = UIAlertAction.init(title: viewModel.addButton, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            let signInController = SignInViewController(nibName: String(describing: SignInViewController.self), bundle: nil)
            let navigationController = UINavigationController(rootViewController: signInController)
            strongSelf.present(navigationController, animated: true, completion: nil)
        })
        return temp
    }
    
    private func cancelAlertAction() -> UIAlertAction {
        let temp = UIAlertAction(title: viewModel.cancelButton, style: .default, handler: nil)
        return temp
    }
    
    private func settingActionSheet() {
        alertMessage.addAction(changeAlertAction())
        alertMessage.addAction(addAlertAction())
        alertMessage.addAction(cancelAlertAction())
    }
    
}

extension UserLibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tempUser = viewModel.user else { return UITableViewCell() }
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
