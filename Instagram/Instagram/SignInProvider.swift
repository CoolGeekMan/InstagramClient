//
//  SignInProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/25/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import Alamofire

class SignInProvider {
    
    internal static let shared = SignInProvider()
    internal let requestParameters = RequestParameters()
    internal let requestValues = RequestValues()
    internal let requestURLs = RequestURLs()
    
    private init() {}
    
    func authorizationURL() -> URL? {
        let stringURL = "\(requestURLs.authorizationURL)?\(requestParameters.clientID)=\(requestValues.clientID)&\(requestParameters.redirectURL)=\(requestValues.redirectURL)&\(requestParameters.responseType)=\(requestValues.responseType)&\(requestParameters.scope)=\(requestValues.scope)"
        guard let url = URL(string: stringURL) else { return nil }
        return url
    }
}
