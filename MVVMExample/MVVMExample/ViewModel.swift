//
//  ViewModel.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ViewModel: ViewModelProtocol {

    private let dataProvider = WorkersProvider.shared
    internal var workers = [Worker]()
    private var listIsChanged = false
    private var needfulWorkers = [Worker]() {
        didSet {
            listIsChanged = oldValue == needfulWorkers ? false : true
        }
    }
    
    internal func fetchWorkers(completion: @escaping () -> ()) {
        dataProvider.workers {[weak self] (tempWorkers) in
            guard let strongSelf = self else { return }
            guard let gettingWorkers = tempWorkers else { return }
            strongSelf.workers = gettingWorkers
            strongSelf.needfulWorkers = gettingWorkers
            completion()
        }
    }
    
    internal func fetchNeedfulWorkers(text: String, haveChanges: @escaping (Bool) -> ()) {
        needfulWorkers = workers.filter { (worker) -> Bool in
            guard worker.name.contains(text) || text == "" else { return false }
            return true
        }
        haveChanges(listIsChanged)
    }
    
    internal func numberOfItemsInSection() -> Int {
        return needfulWorkers.count
    }
    
    internal func titleForItemAt(indexPath: IndexPath) -> String {
        return needfulWorkers[indexPath.row].name
    }
}
