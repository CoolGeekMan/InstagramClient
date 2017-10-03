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
    
    static let count: Int = {
        var max: Int = 0
        while let _ = ListSectionType(rawValue: max) {
            max += 1
        }
        return max
    }()
}

enum ListCellType: Int {
    case header = 0
    case photo = 1
    case date = 2
    case likes = 3
    case comments = 4
}

class UserLibraryListDataSource: NSObject, UserLibraryDataSourceProtocol {
    
    fileprivate struct Constant {
        internal struct CellSize {
            static let indents: CGFloat = 10
            static let headerHeight: CGFloat = 150
            static let displayStyleControlHeight: CGFloat = 30
            static let headerPostHeight: CGFloat = 50
            static let datePostHeight: CGFloat = 25
            static let likesPostHeight: CGFloat = 25
            static let commentsPostHeight: CGFloat = 27
        }
        static let dateFormat = "dd.MM.yyyy HH:mm"
    }
    
    let delegate: UserLibraryDelegate
    let viewModel: UserLibraryViewModel
    var displayStyle: MutableProperty<DisplayStyle>

    init(viewModel: UserLibraryViewModel, delegate: UserLibraryDelegate, displayStyle: MutableProperty<DisplayStyle>) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.displayStyle = displayStyle
    }
    
    private func createdTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.dateFormat
        let stringTime = dateFormatter.string(from: date)
        return stringTime
    }
    
    private func getIndexForSection(indexPath: IndexPath) -> Int {
        let index = indexPath.section - ListSectionType.count
        return index
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
            let index = getIndexForSection(indexPath: indexPath)
            
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

extension UserLibraryListDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize
        
        if let sectionType = ListSectionType(rawValue: indexPath.section){
            switch sectionType {
            case .header:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.headerHeight)
            case .displayStyleControl:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.displayStyleControlHeight)
            }
        } else {
            guard let listCellType = ListCellType(rawValue: indexPath.row) else {
                return CGSize(width: 0, height: 0)
            }
            switch listCellType {
            case .header:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.headerPostHeight)
            case .photo:
                size = CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
            case .date:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.datePostHeight)
            case .likes:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.likesPostHeight)
            case .comments:
                size = CGSize(width: collectionView.frame.width - Constant.CellSize.indents, height: Constant.CellSize.commentsPostHeight)
            }
        }
        return size
    }
}

