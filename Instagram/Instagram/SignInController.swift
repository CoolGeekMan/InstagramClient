//
//  SignInController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/25/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import Alamofire

class SignInController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!
    let viewModel = SignInViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        
        guard let request = viewModel.authorizationRequest() else { return }
        webView.loadRequest(request)
    }
    
}

extension SignInController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.host == "www.getpostman.com" {
            guard let url = request.url?.absoluteString else { return false }
            let token = viewModel.dataParser.accessToken(redirectURL: url)
            return false
        }
        return true
    }
}

