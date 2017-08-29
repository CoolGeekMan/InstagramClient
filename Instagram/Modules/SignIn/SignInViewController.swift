//
//  SignInViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/29/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    fileprivate let viewModel = SignInViewModel()
    
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
                        
            return false
        }
        return true
    }
}
