//
//  UserLibraryBoxDataSource.swift
//  Instagram
//
//  Created by Raman Liulkovich on 9/28/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

enum BoxSectionType: Int {
    case header = 0
    case displayStyleControl = 1
    case sizeControl = 2
    case photo = 3
}

class UserLibraryBoxDataSource: NSObject, UICollectionViewDataSource {
    
    let viewModel: UserLibraryViewModel
    let cellsCount: MutableProperty<Int>
    let displayStyle: MutableProperty<DisplayStyle>
    var setupSlider: ScopedDisposable<AnyDisposable>?

    init(viewModel: UserLibraryViewModel, cellsCount: MutableProperty<Int>, displayStyle: MutableProperty<DisplayStyle>) {
        self.viewModel = viewModel
        self.cellsCount = cellsCount
        self.displayStyle = displayStyle
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
    
    private func photoChooseButtonAction(indexPath: IndexPath, collectionView: UICollectionView) -> CocoaAction<UIButton> {
        return CocoaAction<UIButton>(Action<Void, Void, NSError>{ _ in
            let producer: SignalProducer<Void, NSError> = SignalProducer {[weak self] () -> () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.displayStyle.value = .List
                DispatchQueue.main.async {
                    collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: true)
                }
            }
            return producer
        })
    }
    
    private func setSliderDisposable(slider: UISlider) -> Disposable? {
        return slider.reactive.values.observeValues({ [weak self] (temp) in
            guard let strongSelf = self else {
                return
            }
            let temp = Int(temp)
            if temp != strongSelf.cellsCount.value {
                strongSelf.cellsCount.value = temp
            }
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Global.Cell.boxSectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countCells: Int
        guard let sectionType = BoxSectionType(rawValue: section) else {
            return 0
        }
        switch sectionType {
        case .photo:
            countCells = viewModel.cellCount(displayStyle: .Box)
        default:
            countCells = Global.Cell.countCellsFromControlSection
        }
        return countCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tempUser = viewModel.user else {
            return UICollectionViewCell()
        }
        guard let sectionType = BoxSectionType(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
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
        case .sizeControl:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.sizeControl, for: indexPath) as? SizeControlCell else {
                return UICollectionViewCell()
            }
            
            if let tempSliderDisposable = setSliderDisposable(slider: cell.sizeSlider) {
                setupSlider = .init(tempSliderDisposable)
            }
            return cell
        case .photo:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Global.Cell.photo, for: indexPath) as? PhotoCell else {
                return UICollectionViewCell()
            }
            let index = indexPath.row
            
            if let image = viewModel.photos.value[index].photoImage {
                cell.photo.image = image
            } else {
                viewModel.downloadPhoto(index: index) { (data) in
                    cell.photo.image = UIImage(data: data)
                }
            }
            cell.photoChooseButton.reactive.pressed = photoChooseButtonAction(indexPath: IndexPath.init(row: 1, section: indexPath.row + 2), collectionView: collectionView)
            return cell
        }
    
    }
}

extension UserLibraryBoxDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize
        
        guard let sectionType = BoxSectionType(rawValue: indexPath.section) else {
            return CGSize(width: 0, height: 0)
        }
        
        switch sectionType {
        case .header:
            size = CGSize(width: collectionView.frame.width - 10, height: 150)
        case .displayStyleControl:
            size = CGSize(width: collectionView.frame.width - 10, height: 30)
        case .sizeControl:
            size = CGSize(width: collectionView.frame.width - 10, height: 39)
        default:
            let side = (collectionView.frame.width / CGFloat(cellsCount.value)) - 0.5
            size = CGSize(width: side, height: side)
        }
        
        return size
    }
}
