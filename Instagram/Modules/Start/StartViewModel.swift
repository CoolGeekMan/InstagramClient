//
//  StartViewModel.swift
//  Instagram
//
//  Created by Raman Liulkovich on 8/31/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

class StartViewModel {
    
    private let dataProvider = StartViewDataProvider()
    
    internal func haveUser() -> Bool {
        return dataProvider.haveUser()
    }
}
