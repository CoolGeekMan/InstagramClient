//
//  Worker.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class Worker {
    
    internal let name: String
    internal let age: Int
    internal let position: String
    
    internal init(name: String, age: Int, position: String) {
        self.name = name
        self.age = age
        self.position = position
    }
}
