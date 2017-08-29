//
//  StartViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/29/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let signInViewController = SignInViewController(nibName: String(describing: SignInViewController.self), bundle: nil)
        present(signInViewController, animated: false, completion: nil)
    }
}
