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
        let stringURL = "\(Global.RequestURL.authorizationURL)?\(Global.RequestParameter.clientID)=\(Global.RequestValue.clientID)&\(Global.RequestParameter.redirectURL)=\(Global.RequestValue.redirectURL)&\(Global.RequestParameter.responseType)=\(Global.RequestValue.responseType)&\(Global.RequestParameter.scope)=\(Global.RequestValue.scope)"
        guard let url = URL(string: stringURL) else { return nil }
        return url
    }
    
    internal func userInfo(token: String) {
        let url = "\(Global.RequestURL.userInfoURL)?\(Global.RequestParameter.accessToken)=\(token)"
        
        Alamofire.request(url).responseJSON { (temp) in
            guard let json = temp.result.value else {return}
            print(json)
        }
    }
}
