//
//  UserLibraryListDataSource.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class UserLibraryListDataSource: NSObject, UICollectionViewDataSource {
    
    private struct Constant {
        internal struct ActionSheet {
            internal static let changeButton = "Change user"
            internal static let addButton = "Add user"
            internal static let cancelButton = "Cancel"
        }
        internal struct Cell {
            static let header = "HeaderCell"
            static let post = "PostCell"
            static let control = "ControlCell"
            static let sizeControl = "SizeControlCell"
            static let photo = "PhotoCell"
        }
        internal struct Button {
            static let change = "Change"
        }
    }
    
    let viewModel: UserLibraryViewModel
    let cellsCount: MutableProperty<Int>!
    let displayStyle: MutableProperty<DisplayStyle>

    init(viewModel: UserLibraryViewModel, cellsCount: MutableProperty<Int>, displayStyle: MutableProperty<DisplayStyle>) {
        self.viewModel = viewModel
        self.cellsCount = cellsCount
        self.displayStyle = displayStyle
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount(displayStyle: .List)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let tempUser = viewModel.user else {
            return UICollectionViewCell()
        }
        
        switch indexPath.row {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.Cell.header, for: indexPath) as? HeaderCell else {
                return UICollectionViewCell()
            }
            cell.configure(user: tempUser)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.Cell.control, for: indexPath) as? ControlCell else {
                return UICollectionViewCell()
            }
            
            cell.postListButton.reactive.pressed = CocoaAction(Action<Void, Void, NSError>{ _ in
                let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.displayStyle.value = .List
                }
                return producer
            })
            
            cell.boxListButton.reactive.pressed = CocoaAction(Action<Void, Void, NSError>{ _ in
                let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.displayStyle.value = .Box
                }
                return producer
            })
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.Cell.post, for: indexPath) as? PostCell else {
                return UICollectionViewCell()
            }
            let index = indexPath.row - 2
            cell.configure(user: tempUser, photo: viewModel.photos.value[index])
            
            if let image = viewModel.photos.value[index].photoImage {
                cell.photo.image = image
            } else {
                viewModel.downloadPhoto(index: index) { (data) in
                    cell.photo.image = UIImage(data: data)
                }
            }
            
            cell.commentsCountButton.reactive.pressed = CocoaAction(Action<Void, Void, NSError>{ _ in
                let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                    guard let strongSelf = self else {
                        return
                    }
                    let viewController = CommentsViewController()
                    viewController.viewModel.mediaID = cell.id
                    //strongSelf.navigationController?.pushViewController(viewController, animated: true)
                }
                return producer
            })
            return cell
        }
    }
}

extension UserLibraryListDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize
        
        switch indexPath.row {
        case 0:
            size = CGSize(width: collectionView.frame.width - 10, height: 150)
        case 1:
            size = CGSize(width: collectionView.frame.width - 10, height: 30)
        default:
            size = CGSize(width: collectionView.frame.width, height: 600)
        }
        
        return size
    }
}

