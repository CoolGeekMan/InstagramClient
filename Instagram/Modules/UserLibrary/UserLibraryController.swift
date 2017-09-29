//
//  UserLibraryController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/25/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class UserLibraryController: UIViewController {

    fileprivate struct Constant {
        internal struct ActionSheet {
            internal static let changeButton = "Change user"
            internal static let addButton = "Add user"
            internal static let cancelButton = "Cancel"
        }
        internal struct Cell {
            static let header = "HeaderCell"
            static let post = "PostCell"
            static let control = "ControlCell"
            static let sizeControl = "SizeControlCell"
            static let photo = "PhotoCell"
        }
        internal struct Button {
            static let change = "Change"
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    internal let viewModel = UserLibraryViewModel()
    private lazy var change: UIBarButtonItem = UIBarButtonItem(title: Constant.Button.change, style: .done, target: self, action: #selector(presentActionSheet))
    let alertMessage: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var cellsCount: MutableProperty<Int> = MutableProperty(2)
    fileprivate var refresher = UIRefreshControl()

    var setupData: ScopedDisposable<AnyDisposable>?
    var setupCelsCount: ScopedDisposable<AnyDisposable>?
    var setupDisplayStyle: ScopedDisposable<AnyDisposable>?
    
    var displayStyle: MutableProperty<DisplayStyle> = MutableProperty(DisplayStyle.Box)

    var boxDelegate: UserLibraryBoxDataSource!
    var listDelegate: UserLibraryListDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: Constant.Cell.header, bundle: nil), forCellWithReuseIdentifier: Constant.Cell.header)
        collectionView.register(UINib(nibName: Constant.Cell.control, bundle: nil), forCellWithReuseIdentifier: Constant.Cell.control)
        collectionView.register(UINib(nibName: Constant.Cell.sizeControl, bundle: nil), forCellWithReuseIdentifier: Constant.Cell.sizeControl)
        collectionView.register(UINib(nibName: Constant.Cell.photo, bundle: nil), forCellWithReuseIdentifier: Constant.Cell.photo)
        collectionView.register(UINib(nibName: Constant.Cell.post, bundle: nil), forCellWithReuseIdentifier: Constant.Cell.post)


        boxDelegate = UserLibraryBoxDataSource(viewModel: viewModel, cellsCount: cellsCount, displayStyle: displayStyle)
        listDelegate = UserLibraryListDataSource(viewModel: viewModel, cellsCount: cellsCount, displayStyle: displayStyle)
        
        collectionView.dataSource = boxDelegate
        collectionView.delegate = boxDelegate
        
        viewModel.fetchUser()
        
        guard let userName = viewModel.userName() else {
            return
        }
        navigationItem.title = userName
        navigationItem.rightBarButtonItems = [change]
        
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refresher)
        
        settingActionSheet()
        
        if !viewModel.haveMedia() {
            viewModel.media(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.viewModel.fetchPhotos()
            })
        } else {
            viewModel.fetchPhotos()
        }
        
        if let tempCelsCountDisposable = setCelsCountDisposable() {
            setupCelsCount = .init(tempCelsCountDisposable)
        }
        
        if let tempDataDisposable = setDataDisposable() {
            setupData = .init(tempDataDisposable)
        }
        
        if let tempDisplayStyleDissposable = setDisplayStyleDisposable() {
            setupDisplayStyle = .init(tempDisplayStyleDissposable)
        }
        
        collectionView.reloadData()
    }

    func setDataDisposable() -> Disposable? {
        return viewModel.photos.signal.observe { [weak self] (photos) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.collectionView.reloadData()
        }
    }
    
    func setCelsCountDisposable() -> Disposable? {
        return cellsCount.signal.observe { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.collectionView.reloadData()
        }
    }
    
    func setDisplayStyleDisposable() -> Disposable? {
        return displayStyle.signal.observe { [weak self] (style) in
            guard let strongSelf = self, let tempStyle = style.value else {
                return
            }
            switch tempStyle {
            case .Box:
                strongSelf.collectionView.dataSource = strongSelf.boxDelegate
                strongSelf.collectionView.delegate = strongSelf.boxDelegate
            case .List:
                strongSelf.collectionView.dataSource = strongSelf.listDelegate
                strongSelf.collectionView.delegate = strongSelf.listDelegate
            }
            strongSelf.collectionView.reloadData()
        }
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
                strongSelf.refresher.endRefreshing()
            })
        }
    }
    
}

extension UserLibraryController {
    
    @objc fileprivate func presentActionSheet() {
        present(alertMessage, animated: true, completion: nil)
    }
    
    fileprivate func selectionUserAction(user: User) -> UIAlertAction {
        let temp = UIAlertAction(title: "\(user.userName)", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.saveUserID(id: user.id)
            let tabBarController = UITabBarController()
            let userViewController = UserLibraryController(nibName: String(describing: UserLibraryController.self), bundle: nil)
            let navigationController = UINavigationController(rootViewController: userViewController)
            navigationController.title = Global.TabBarTitle.user
            tabBarController.viewControllers = [navigationController]
            strongSelf.present(tabBarController, animated: false, completion: nil)
        })
        return temp
    }
    
    private func changeAlertAction() -> UIAlertAction {
        let action = UIAlertAction.init(title: Constant.ActionSheet.changeButton, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else {
                return
            }
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
        let temp = UIAlertAction.init(title: Constant.ActionSheet.addButton, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            let signInController = SignInViewController(nibName: String(describing: SignInViewController.self), bundle: nil)
            let navigationController = UINavigationController(rootViewController: signInController)
            strongSelf.present(navigationController, animated: true, completion: nil)
        })
        return temp
    }
    
    private func cancelAlertAction() -> UIAlertAction {
        let temp = UIAlertAction(title: Constant.ActionSheet.cancelButton, style: .default, handler: nil)
        return temp
    }
    
    fileprivate func settingActionSheet() {
        alertMessage.addAction(changeAlertAction())
        alertMessage.addAction(addAlertAction())
        alertMessage.addAction(cancelAlertAction())
    }
    
}
