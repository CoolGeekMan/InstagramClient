//
//  SignInDataParser.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class SignInDataParser {
    
    internal func accessToken(redirectURL: String) -> String? {
        let temp = redirectURL.components(separatedBy: "access_token=")
        guard temp.count > 1 else { return nil }
        return temp[1]
    }
}
