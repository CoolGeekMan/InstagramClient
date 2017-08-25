//
//  Worker.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class Worker: Equatable {
    
    internal let name: String
    internal let age: Int
    internal let position: String
    
    internal init(name: String, age: Int, position: String) {
        self.name = name
        self.age = age
        self.position = position
    }
    
    static func ==(lhs: Worker, rhs: Worker) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.age == rhs.age &&
            lhs.position == rhs.position
    }
}
