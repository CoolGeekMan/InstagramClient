//
//  WorkersProvider.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import Alamofire

class WorkersProvider {
    
    internal static let shared = WorkersProvider()
    
    private init() {}
    
    internal func workers(completion: @escaping ([Worker]?) -> ()) {
        Alamofire.request("https://api.myjson.com/bins/tgbnh").responseJSON { (response) in
            guard let json = response.result.value as? [[String: Any]] else { return }
            var result = [Worker]()
            for temp in json {
                if let name = temp["name"] as? String, let tempAge = temp["age"] as? String, let position = temp["position"] as? String, let age = Int(tempAge) {
                    let worker = Worker(name: name, age: age, position: position)
                    result.append(worker)
                }
            }
            completion(result)
        }
    }
}
