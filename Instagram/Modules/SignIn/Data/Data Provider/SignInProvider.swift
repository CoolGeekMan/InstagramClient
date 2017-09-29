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
        guard let url = URL(string: stringURL) else {
            return nil
        }
        return url
    }
    
    internal func userInfo(token: String, result: @escaping (User?) -> ()) {
        let url = "\(Global.RequestURL.userInfoURL)?\(Global.RequestParameter.accessToken)=\(token)"
        
        Alamofire.request(url).responseJSON { (temp) in
            guard let json = temp.result.value as? [String: Any] else {
                return
            }
            do {
                let user = try User(json: json, token: token)
                result(user)
            } catch {
                print(error)
            }
        }
    }
    
    internal func image(url: String, result: @escaping (UIImage?) -> ()) {
        Alamofire.request(url).responseData { (response) in
            guard let data = response.data else {
                return
            }
            guard let picture = UIImage(data: data) else {
                return
            }
            result(picture)
        }
    }
    
}
