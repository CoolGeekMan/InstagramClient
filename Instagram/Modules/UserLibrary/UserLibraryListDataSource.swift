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

enum ListSectionType: Int {
    case header = 0
    case displayStyleControl = 1
}

enum ListCellType: Int {
    case header = 0
    case photo = 1
    case date = 2
    case likes = 3
    case comments = 4
}

class UserLibraryListDataSource: NSObject, UICollectionViewDataSource {
    
    let delegate: UserLibraryDelegate
    let viewModel: UserLibraryViewModel
    let cellsCount: MutableProperty<Int>!
    let displayStyle: MutableProperty<DisplayStyle>

    init(viewModel: UserLibraryViewModel, delegate: UserLibraryDelegate, cellsCount: MutableProperty<Int>, displayStyle: MutableProperty<DisplayStyle>) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.cellsCount = cellsCount
        self.displayStyle = displayStyle
    }
    
    private func createdTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let stringTime = dateFormatter.string(from: date)
        return stringTime
    }
    
    private func postListButtonAction() -> CocoaAction<UIButton> {
        return CocoaAction<UIButton>(Action<Void, Void, NSError>{ _ in
            let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.displayStyle.value = .List
            }
            return producer
        })
    }
    
    private func boxListButtonAction() -> CocoaAction<UIButton> {
        return CocoaAction<UIButton>(Action<Void, Void, NSError>{ _ in
            let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.displayStyle.value = .Box
            }
            return producer
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.cellCount(displayStyle: .List)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countCells: Int
        
        if let sectionType = ListSectionType(rawValue: section) {
            switch sectionType {
            case .header:
                countCells = Global.Cell.countCellsFromControlSection
            case .displayStyleControl:
                countCells = Global.Cell.countCellsFromControlSection
            }
        } else {
            countCells = Global.Cell.countCellsFromPostSection
        }

        return countCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tempUser = viewModel.user else {
            return UICollectionViewCell()
        }
        
        if let sectionType = ListSectionType(rawValue: indexPath.section) {
            switch sectionType {
            case .header:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.header, for: indexPath) as? HeaderCell else {
                    return UICollectionViewCell()
                }
                cell.configure(user: tempUser)
                return cell
            case .displayStyleControl:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.control, for: indexPath) as? ControlCell else {
                    return UICollectionViewCell()
                }
                
                cell.postListButton.reactive.pressed = postListButtonAction()
                cell.boxListButton.reactive.pressed = boxListButtonAction()
                
                return cell
            }
        } else {
            guard let listCellType = ListCellType(rawValue: indexPath.row) else {
                return UICollectionViewCell()
            }
            let index = indexPath.section - 2
            switch listCellType {
            case .header:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.headerPost, for: indexPath) as? HeaderPostCell else {
                    return UICollectionViewCell()
                }
                cell.profilePicture.image = tempUser.profilePicture
                cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.width / 2
                cell.userName.text = tempUser.userName
                return cell
            case .photo:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.photoPost, for: indexPath) as? PhotoPostCell else {
                    return UICollectionViewCell()
                }
                if let image = viewModel.photos.value[index].photoImage {
                    cell.photo.image = image
                } else {
                    viewModel.downloadPhoto(index: index) { (data) in
                        cell.photo.image = UIImage(data: data)
                    }
                }
                
                return cell
            case .date:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.datePost, for: indexPath) as? DatePostCell else {
                    return UICollectionViewCell()
                }
                cell.date.text = createdTime(date: viewModel.photos.value[index].createdTime as Date)
                return cell
            case .likes:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.likesPost, for: indexPath) as? LikesPostCell else {
                    return UICollectionViewCell()
                }
                cell.likesCount.text = "\(viewModel.photos.value[index].likesCount) likes"
                return cell
            case .comments:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.commentsPost, for: indexPath) as? CommentsPostCell else {
                    return UICollectionViewCell()
                }
                cell.commentsCountButton.setTitle("View all \(viewModel.photos.value[index].commentsCount) comments", for: .normal)
                cell.id = viewModel.photos.value[index].id
                
                                cell.commentsCountButton.reactive.pressed = CocoaAction(Action<Void, Void, NSError>{ _ in
                                     let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                                     guard let strongSelf = self else {
                                          return
                                     }
                                        strongSelf.delegate.navigatToCommentsViewController(mediaID: cell.id)
                                     }
                                     return producer
                                })
                
                return cell
            }
        }
    }
}

extension UserLibraryListDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize
        
        if let sectionType = ListSectionType(rawValue: indexPath.section){
            switch sectionType {
            case .header:
                size = CGSize(width: collectionView.frame.width - 10, height: 150)
            case .displayStyleControl:
                size = CGSize(width: collectionView.frame.width - 10, height: 30)
            }
        } else {
            guard let listCellType = ListCellType(rawValue: indexPath.row) else {
                return CGSize(width: 0, height: 0)
            }
            switch listCellType {
            case .header:
                size = CGSize(width: collectionView.frame.width - 10, height: 50)
            case .photo:
                size = CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
            case .date:
                size = CGSize(width: collectionView.frame.width - 10, height: 25)
            case .likes:
                size = CGSize(width: collectionView.frame.width - 10, height: 25)
            case .comments:
                size = CGSize(width: collectionView.frame.width - 10, height: 27)
            }
        }
        return size
    }
}

