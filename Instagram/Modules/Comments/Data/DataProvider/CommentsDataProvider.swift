//
//  CommentsDataProvider.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/13/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import Alamofire

class CommentsDataProvider {
    
    internal func mediaComments(token: String, mediaID: String, result: @escaping ([String: Any]) -> ()) {
        let url = "\(Global.RequestURL.mediaURL)\(mediaID)\(Global.RequestURL.comments)?\(Global.RequestParameter.accessToken)=\(token)"
        
        Alamofire.request(url).responseJSON { (temp) in
            guard let json = temp.result.value as? [String: Any] else {
                return
            }
            result(json)
        }
    }
    
    internal func userImage(link: String, result: @escaping (Data?) -> ())  {
        Alamofire.request(link).responseData { (response) in
            guard let data = response.data else {
                return
            }
            result(data)
        }
    }
}
