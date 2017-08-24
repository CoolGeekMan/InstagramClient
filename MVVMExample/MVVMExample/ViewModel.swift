//
//  ViewModel.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import ReactiveCocoa

//var workers: Property<[Worker]>

class ViewModel: ViewModelProtocol {

    private let dataProvider = WorkersProvider.shared
    internal var workers = [Worker]()
    private var needfulWorkers = [Worker]()
    
    internal func fetchWorkers(completion: @escaping () -> ()) {
        dataProvider.workers {[weak self] (tempWorkers) in
            guard let strongSelf = self else { return }
            guard let gettingWorkers = tempWorkers else { return }
            strongSelf.workers = gettingWorkers
            strongSelf.needfulWorkers = gettingWorkers
            completion()
        }
    }
    
    internal func fetchNeedfulWorkers(text: String) {
        needfulWorkers = workers.flatMap({ (worker) -> Worker? in
            guard worker.name.contains(text) || text == "" else { return nil }
            return worker
        })
    }
    
    internal func numberOfItemsInSection() -> Int {
        return needfulWorkers.count
    }
    
    internal func titleForItemAt(indexPath: IndexPath) -> String {
        return needfulWorkers[indexPath.row].name
    }
}
