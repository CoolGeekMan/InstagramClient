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
        
    internal func authorizationURL() -> URL? {
        let stringURL = "\(Global.RequestURLs.authorizationURL)?\(Global.RequestParameters.clientID)=\(Global.RequestValues.clientID)&\(Global.RequestParameters.redirectURL)=\(Global.RequestValues.redirectURL)&\(Global.RequestParameters.responseType)=\(Global.RequestValues.responseType)&\(Global.RequestParameters.scope)=\(Global.RequestValues.scope)"
        guard let url = URL(string: stringURL) else { return nil }
        return url
    }
}
