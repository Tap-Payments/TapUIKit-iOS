//
//  TapCardPhoneBarListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa
import SnapKit

public class TapCardPhoneBarListViewModel {
    
    
    internal var dataSourceObserver:BehaviorRelay<[TapCardPhoneIconViewModel]> = .init(value: [])
    
    public var dataSource:[TapCardPhoneIconViewModel] = [] {
        didSet{
            dataSourceObserver.accept(dataSource)
        }
    }
    
    public init(dataSource:[TapCardPhoneIconViewModel] = []) {
        self.dataSource = dataSource
    }
    
    internal func generateViews(with maxWidth:CGFloat = 50) -> [TapCardPhoneIconView] {
        
        return dataSource.map {
            let tapCardPhoneIconView:TapCardPhoneIconView = .init()
            tapCardPhoneIconView.setupView(with: $0)
            tapCardPhoneIconView.snp.remakeConstraints { $0.height.equalTo(maxWidth).priority(.medium) }
            return tapCardPhoneIconView
        }
    }
}
