//
//  MenuTabBarController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/30/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class MenuTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let userLibraryViewController = UserLibraryViewController(nibName: String(describing: UserLibraryViewController.self), bundle: nil)
        let navigationController = NavigationViewController(rootViewController: userLibraryViewController)
        navigationController.title = "User"
        viewControllers = [navigationController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
    
