//
//  UserLibraryDataSourceProtocol.swift
//  Instagram
//
//  Created by Raman Liulkovich on 10/3/17.
//  Copyright © 2017 Raman Liulkovich. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

protocol UserLibraryDataSourceProtocol: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var displayStyle: MutableProperty<DisplayStyle> { get set }
    var viewModel: UserLibraryViewModel { get }
    
}

extension UserLibraryDataSourceProtocol {
    
    func postListButtonAction() -> CocoaAction<UIButton> {
        return CocoaAction<UIButton>(Action<Void, Void, NSError>{ _ in
            let producer: SignalProducer<Void, NSError> = SignalProducer { () -> () in
                self.displayStyle.value = .List
            }
            return producer
        })
    }
    
    func boxListButtonAction() -> CocoaAction<UIButton> {
        return CocoaAction<UIButton>(Action<Void, Void, NSError>{ _ in
            let producer: SignalProducer<Void, NSError> = SignalProducer { () -> () in
                self.displayStyle.value = .Box
            }
            return producer
        })
    }
    
}
