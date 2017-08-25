//
//  Worker.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class Worker: NSObject {
    
    internal let name: String
    internal let age: Int
    internal let position: String
    
    internal init(name: String, age: Int, position: String) {
        self.name = name
        self.age = age
        self.position = position
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let tempObject = object as? Worker else { return false }
        guard name == tempObject.name,
            age == tempObject.age,
            position == tempObject.position else { return false }
        return true
    }
}
