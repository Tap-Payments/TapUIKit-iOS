//
//  TapCellModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// The delegate used to send events and data changes from the view model to the subscriber, will have the methods needed to communicate between the view model and other entities
@objc public protocol TapCellViewModelDelegate {
    /**
     Method used to pass back an event to the delegate that any of the view model data changed
     - Parameter viewModel : The view model in interest which has one or more data changed
     */
    func viewModelDidChange(viewModel:TapCellViewModel)
}

/// This class represents a generic super class to have one type used in configuring different tap custom cells, each cell will has its own viewmodel that extends this one
public class TapCellViewModel: NSObject {
    /// The delegate used to send events and data changes from the view model to the subscriber
    @objc public var viewModelDelegate:TapCellViewModelDelegate?
    
    
    internal func notifyViewModelChanged(viewModel:TapChipCellViewModel) {
        if let nonNullDelegate = viewModelDelegate {
            nonNullDelegate.viewModelDidChange(viewModel: viewModel)
        }
    }
}

