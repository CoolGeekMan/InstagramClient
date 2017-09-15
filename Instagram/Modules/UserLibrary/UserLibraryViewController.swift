//
//  UserLibraryViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class UserLibraryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var refresher = UIRefreshControl()
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
        
        tableView.register(UINib(nibName: "HeaderViewCell", bundle: nil), forCellReuseIdentifier: "HeaderViewCell")
        tableView.register(UINib(nibName: "PostViewCell", bundle: nil), forCellReuseIdentifier: "PostViewCell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refresher)
        
        viewModel.fetchUser()
        
        guard let userName = viewModel.userName() else { return }
        navigationItem.title = userName
        navigationItem.rightBarButtonItems = [change]

        settingActionSheet()
        
        if !viewModel.haveMedia() {
            viewModel.media(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.viewModel.fetchPhotos()
                strongSelf.tableView.reloadData()
            })
        } else {
            viewModel.fetchPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @objc private func refreshData() {
        viewModel.removeOldData()
        viewModel.reloadData { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewModel.fetchUser()
            
            strongSelf.viewModel.media(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.viewModel.fetchPhotos()
                strongSelf.tableView.reloadData()
                strongSelf.refresher.endRefreshing()
            })
        }
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
        return viewModel.cellCount()
    }
    
    func configureHeaderCell(_ cell: HeaderViewCell, at indexPath: IndexPath) {
        guard let tempUser = viewModel.user else { return }
        
        cell.runBotButton.layer.borderWidth = 1.0
        cell.runBotButton.layer.cornerRadius = 5
        
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.width / 2
        cell.followedBy.text = "\(tempUser.followedBy)"
        cell.follows.text = "\(tempUser.follows)"
        cell.media.text = "\(tempUser.media)"
        cell.fullName.text = tempUser.fullName
        cell.profilePicture.image = tempUser.profilePicture
    }

    func configurePostCell(_ cell: PostViewCell, at indexPath: IndexPath) {
        guard let tempUser = viewModel.user else { return }
        let index = indexPath.row  - 1
        
        cell.profilePicture.image = tempUser.profilePicture
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.width / 2
        cell.userName.text = tempUser.userName
        cell.date.text = "published \(viewModel.photos[index].createdTime)"
        cell.likesCount.text = "\(viewModel.photos[index].likesCount) likes"
        cell.id = viewModel.photos[index].id
        cell.commentsCountButton.setTitle("View all \(viewModel.photos[index].commentsCount) comments", for: .normal)
        
        if !viewModel.checkImage(index: index) {
            viewModel.downloadPhoto(index: index) { (data) in
                cell.photo.image = UIImage(data: data)
            }
        } else {
            guard let image = viewModel.photos[index].image else {
                return
            }
            cell.photo.image = UIImage(data: image as Data)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderViewCell", for: indexPath) as? HeaderViewCell else {
                return UITableViewCell()
            }
            configureHeaderCell(cell, at: indexPath)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostViewCell", for: indexPath) as? PostViewCell else {
                return UITableViewCell()
            }
            configurePostCell(cell, at: indexPath)
            cell.commentsCountButton.reactive.pressed = CocoaAction(Action<Void, Void, NSError>{ _ in
                let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                    guard let strongSelf = self else {
                        return
                    }
                    let viewController = CommentsViewController()
                    viewController.viewModel.mediaID = cell.id
                    strongSelf.navigationController?.pushViewController(viewController, animated: true)
                }
                return producer
            })
            return cell
        }
    }
    
}

