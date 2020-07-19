//
//  TapActionButtonViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// A protocol to communicate with the view controller with this view model
internal protocol TapActionButtonViewDelegate {
    
    /// Instructs the view to reload itself with respect to the new data availble inside the view model
    func reload()
    
    /** Instructs the button view to start with the loading animation
     - Parameter completion: A block to be called once the collapsing is done
     */
    func startLoading(completion:()->()?)
    
    /**
     Instructs the button to end loading with a given result
     - Parameter success: Indicates whether the button shall transform from loading to success or failing state
     - Parameter completion: A block to be called once the success or failure has been shown to the user (POST status block)
     */
    func endLoading(with success:Bool,completion:()->()?)
}

/// Represents the view model that controls the events and the look and feel for the Tap Action Button View
@objc public class TapActionButtonViewModel:NSObject {
    
    /// Represents the status of the action button
    @objc public var buttonStatus:TapActionButtonStatusEnum = .InvalidPayment{
        didSet{
            buttonStatusChanged()
        }
    }
    
    /// A block representing the action to be executed when the button is clicked, please assign this accordignly based on the latest action required/fied from the main checkout screen
    @objc public var buttonActionBlock:()->() = {}
    
    /** Instructs the button view to start with the loading animation
     - Parameter completion: A block to be called once the collapsing is done
     */
    @objc public func startLoading(completion:()->() = {}) {
        viewDelegate?.startLoading(completion: completion)
    }
    
    
    @objc public override init() {
        super.init()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ActionButtonStatusChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StnNotificationExist(_:)), name: NSNotification.Name(rawValue: "ActionButtonStatusChanged"), object: nil)
    }
    
    @objc func StnNotificationExist(_ notification:NSNotification)
    {
        if let status:TapActionButtonStatusEnum = notification.userInfo!["newStatus"] as? TapActionButtonStatusEnum
        {
            self.buttonStatus = status
        }
    }
    
    /**
     Instructs the button to end loading with a given result
     - Parameter success: Indicates whether the button shall transform from loading to success or failing state
     - Parameter completion: A block to be called once the success or failure has been shown to the user (POST status block)
     */
    @objc public func endLoading(with success:Bool,completion:()->() = {}) {
        viewDelegate?.endLoading(with: success, completion: completion)
    }
    
    
    /// A protocol to communicate with the view controller with this view model
    internal var viewDelegate:TapActionButtonViewDelegate?
    
    
    /// Handles the logic needed when the status of the button changes
    internal func buttonStatusChanged() {
        // Inform the view, that he needs to reload itself based on the new status
        viewDelegate?.reload()
    }
    
    /// Handles the logic needed when the action button is clicked, this will be fired from the view itself
    internal func didClickButton() {
        // perform the latest action block defined from the parent caller
        buttonActionBlock()
    }
}
