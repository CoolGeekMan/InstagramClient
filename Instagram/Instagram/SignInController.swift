//
//  SignInController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/25/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit

class SignInController: UIViewController {

    @IBOutlet private weak var signInButton: UIButton!
    
    fileprivate let viewModel = SignInViewModel()
    private var webView: SignInView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func signIn(_ sender: Any) {
        webView = UINib(nibName: "SignInView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SignInView
        
        guard let tempWebView = webView else { return }
        guard let request = viewModel.authorizationRequest() else { return }

        view.addSubview(tempWebView)
        tempWebView.wevView.delegate = self
        tempWebView.wevView.loadRequest(request)
    }
}

extension SignInController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.host == viewModel.redirectHOST() {
            guard let url = request.url?.absoluteString else { return false }
            guard let token = viewModel.dataParser.accessToken(redirectURL: url) else { return false }
            viewModel.saveToken(token: token)
            webView.isHidden = true
            return false
        }
        return true
    }
}

