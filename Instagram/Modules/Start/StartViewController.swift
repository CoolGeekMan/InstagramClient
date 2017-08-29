//
//  StartViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/29/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet private weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func signIn(_ sender: Any) {
        let signInViewController = SignInViewController(nibName: String(describing: SignInViewController.self), bundle: nil)
        present(signInViewController, animated: false, completion: nil)
    }
}
