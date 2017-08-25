//
//  ViewModelProtocol.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/24/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation

protocol ViewModelProtocol {
    
    var workers: [Worker] { get set }
    
    func fetchWorkers(completion: @escaping () -> ())
    func fetchNeedfulWorkers(text: String, haveChanges: @escaping (Bool) -> ())
    func numberOfItemsInSection() -> Int
    func titleForItemAt(indexPath: IndexPath) -> String

}
