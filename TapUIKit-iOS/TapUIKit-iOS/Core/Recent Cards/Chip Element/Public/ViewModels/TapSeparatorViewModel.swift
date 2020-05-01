//
//  TapSeparatorViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// This class represents a generic super class to have one type used in configuring different tap custom cells, each cell will has its own viewmodel that extends this one
@objc public class TapSeparatorViewModel: TapCellViewModel {
    
    internal typealias SeparatorConfigurator = CollectionCellConfigurator<TapSeparatorCollectionViewCell, TapSeparatorViewModel>
    
    override func convertToCellConfigrator() -> CellConfigurator {
        return SeparatorConfigurator.init(item: self)
    }
    
}
