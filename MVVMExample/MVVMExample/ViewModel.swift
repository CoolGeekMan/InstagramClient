//
//  ViewModel.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveCocoa

//var workers: Property<[Worker]>

class ViewModel: ViewModelProtocol {

    private let dataProvider = WorkersProvider.shared
    internal var workers = [Worker]()
    internal var needfulWorkers = [Worker]()
    
    /*
    internal init(searchBar: UISearchBar, tableView: UITableView) {
        searchBar.reactive.continuousTextValues.observeValues {[weak self] (tempText) in
            guard let strongSelf = self else { return }
            guard let text = tempText else { return }
            
            strongSelf.needfulWorkers = strongSelf.workers.flatMap({ (worker) -> Worker? in
                if worker.name.contains(text) || text == "" {
                    return worker
                }
                return nil
            })
            
            tableView.reloadData()
        }
    }*/
    
    func fetchWorkers(completion: @escaping () -> ()) {
        dataProvider.workers {[weak self] (tempWorkers) in
            guard let strongSelf = self else { return }
            guard let gettingWorkers = tempWorkers else { return }
            strongSelf.workers = gettingWorkers
            strongSelf.needfulWorkers = gettingWorkers
            completion()
        }
    }
    
    internal func numberOfItemsInSection() -> Int {
        return needfulWorkers.count
    }
    
    internal func titleForItemAt(indexPath: IndexPath) -> String {
        return needfulWorkers[indexPath.row].name
    }
}
