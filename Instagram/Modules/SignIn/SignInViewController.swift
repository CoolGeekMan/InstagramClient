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
    private lazy var cancel: UIBarButtonItem = {
        return UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSignInController))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearCache()
        
        guard let request = viewModel.authorizationRequest() else { return }
        webView.scrollView.bounces = false
        webView.delegate = self
        webView.loadRequest(request)
        
        navigationItem.title = "Sign In"
        navigationItem.leftBarButtonItems = [cancel]
    }
    
    @objc private func dismissSignInController() {
        dismiss(animated: true, completion: nil)
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
                    guard let id = strongSelf.viewModel.userID() else { return }
                    strongSelf.viewModel.saveUser()
                    strongSelf.viewModel.saveUserID(id: id)
                    let tabBarController = UITabBarController()
                    let userViewController = UserLibraryViewController(nibName: String(describing: UserLibraryViewController.self), bundle: nil)
                    let navigationController = UINavigationController(rootViewController: userViewController)
                    navigationController.title = "User"
                    tabBarController.viewControllers = [navigationController]
                    strongSelf.present(tabBarController, animated: false, completion: nil)
                })
            })
            return false
        }
        return true
    }
}

extension SignInViewController {
    
    fileprivate func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
