//
//  TapHintViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
/// A protocol to be used to fire functions and events in the associated view
internal protocol TapHintViewDelegate {
    /// A method to instruc the view to reload itself to respond to new status
    func reloadHintView()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapHintViewModelDelegate {
    /**
        An event will be fired once the hint view is clicked
     - Parameter viewModel: The associated view model with the clicked hint vie
     */
    @objc func hintViewClicked(with viewModel:TapHintViewModel)
}

/// The view model that controls the tap hint view
@objc public class TapHintViewModel:NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate:TapHintViewDelegate?
    /// The status of this hint
    @objc public var tapHintViewStatus:TapHintViewStatusEnum = .Default {
        didSet{
            // Upon status change, the associated view needs to reload itself
            viewDelegate?.reloadHintView()
        }
    }
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapHintViewModelDelegate?
    
    /**
     Creates a view model with the provided status
     - Parameter tapHintViewStatus: The status of this hint
     */
    @objc public init(with tapHintViewStatus:TapHintViewStatusEnum) {
        super.init()
        defer {
            self.tapHintViewStatus = tapHintViewStatus
        }
    }
    
    /// Inform the view model with the click action happened on the hint view
    internal func hintViewClicked() {
        delegate?.hintViewClicked(with: self)
    }
    
    
}
