//
//  SignInViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class SignInViewModel {
    
    private let dataProvider = SignInProvider()
    internal let dataParser = SignInDataParser()
    
    internal func authorizationRequest() -> URLRequest? {
        guard let url = dataProvider.authorizationURL() else { return nil }
        let request = URLRequest(url: url)
        return request
    }
    
    internal func redirectHOST() -> String {
        return Global.RequestURL.redirectHOST
    }
}
