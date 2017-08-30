//
//  SignInViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/29/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!
    
    fileprivate let viewModel = SignInViewModel()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let request = viewModel.authorizationRequest() else { return }
        webView.scrollView.bounces = false
        webView.delegate = self
        webView.loadRequest(request)
    }
}

extension SignInViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.host == viewModel.redirectHOST() {
            guard let url = request.url?.absoluteString else { return false }
            guard let token = viewModel.dataParser.accessToken(redirectURL: url) else { return false }
            viewModel.userData(token: token, completion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.userImage(completion: {
                    strongSelf.viewModel.saveUser()
                    let userLibraryViewController = UserLibraryViewController(nibName: String(describing: UserLibraryViewController.self), bundle: nil)
                    strongSelf.present(userLibraryViewController, animated: false, completion: nil)
                })
            })
            return false
        }
        return true
    }
}
