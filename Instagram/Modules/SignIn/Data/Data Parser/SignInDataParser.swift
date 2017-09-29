//
//  SignInDataParser.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class SignInDataParser {
    
    private struct Constant {
        internal struct Separator {
            internal static let forRedirectURL = "access_token="
        }
    }
    
    internal func accessToken(redirectURL: String) -> String? {
        let temp = redirectURL.components(separatedBy: Constant.Separator.forRedirectURL)
        guard temp.count > 1 else {
            return nil
        }
        return temp[1]
    }
    
}
