//
//  CommentsViewController.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/13/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import CoreData

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let viewModel = CommentsViewModel()
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Comment>!
    fileprivate let coreDataManager = CoreDataManager(modelName: "Instagram")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFetchedResultController()
        navigationItem.title = "Comments"
        
        tableView.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: "CommentViewCell")
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        viewModel.fetchUser()
        
        if !viewModel.haveComment() {
            viewModel.comments(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fetchComments()
                strongSelf.tableView.reloadData()
            })
        } else {
            fetchComments()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setFetchedResultController() {
        let fetchRequest: NSFetchRequest<Comment> = Comment.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "mediaID == %@", viewModel.mediaID)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func fetchComments() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
}

extension CommentsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell as! CommentViewCell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}

extension CommentsViewController: UITableViewDataSource {
    
    func configureCell(_ cell: CommentViewCell, at indexPath: IndexPath) {
        let comment = fetchedResultsController.object(at: indexPath)
        cell.userPhoto.layer.cornerRadius = cell.userPhoto.bounds.width / 2 
        cell.comment.text = comment.text
        cell.userName.text = comment.username
        
        guard let time = comment.createdTime else {
            return
        }
        
        cell.createdTime.text = "\(time)"
        
        if let image = comment.image {
            cell.userPhoto.image = UIImage(data: image as Data)
        } else {
            guard let link = comment.imageLink else {
                return
            }
            viewModel.downloadImage(link: link, result: {[weak self] (data) in
                guard let strongSelf = self else {
                    return
                }
                guard let tempData = data else {
                    return
                }
                cell.userPhoto.image = UIImage(data: tempData)
                guard let id = comment.id else {
                    return
                }
                strongSelf.viewModel.saveImage(id: id, data: tempData as NSData)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentViewCell", for: indexPath) as? CommentViewCell else {
            return UITableViewCell()
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
}
