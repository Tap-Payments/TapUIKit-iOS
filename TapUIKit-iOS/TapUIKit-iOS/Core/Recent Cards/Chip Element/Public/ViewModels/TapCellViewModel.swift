//
//  TapCellModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// This class represents a generic super class to have one type used in configuring different tap custom cells, each cell will has its own viewmodel that extends this one
public class TapCellViewModel: NSObject {
    
    /**
    Method used to pass back an event to the delegate that any of the view model data changed
    - Parameter viewModel : The view model in interest which has one or more data changed
    */
    internal lazy var viewModelDidChange:((TapChipCellViewModel) -> ())? = nil
    
    internal func notifyViewModelChanged(viewModel:TapChipCellViewModel) {
        if let nonNullChangeBlock = viewModelDidChange {
            nonNullChangeBlock(viewModel)
        }
    }
    
    internal func convertToCellConfigrator() -> CellConfigurator {
        fatalError("Should be implemented by sub classes")
    }
}

