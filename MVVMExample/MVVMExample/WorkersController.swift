//
//  WorkersController.swift
//  MVVMExample
//
//  Created by Raman Liulkovich on 8/23/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveCocoa

class WorkersController: UIViewController {

    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var workersTable: UITableView!
    
    fileprivate var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchWorkers { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.workersTable.reloadData()
        }
        
        searchBar.reactive.continuousTextValues.observeValues {[weak self] (tempText) in
            guard let strongSelf = self else { return }
            guard let text = tempText else { return }
            
            strongSelf.viewModel.needfulWorkers = strongSelf.viewModel.workers.flatMap({ (worker) -> Worker? in
                if worker.name.contains(text) || text == "" {
                    return worker
                }
                return nil
            })
            
            strongSelf.workersTable.reloadData()
        }
    }
}

extension WorkersController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.titleForItemAt(indexPath: indexPath)
        return cell
    }
}
