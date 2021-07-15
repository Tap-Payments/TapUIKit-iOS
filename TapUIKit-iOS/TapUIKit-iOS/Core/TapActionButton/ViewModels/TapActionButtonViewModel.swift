//
//  TapActionButtonViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UIImage
/// A protocol to communicate with the view controller with this view model
internal protocol TapActionButtonViewDelegate {
    
    /// Instructs the view to reload itself with respect to the new data availble inside the view model
    func reload()
    
    /** Instructs the button view to start with the loading animation
     - Parameter completion: A block to be called once the collapsing is done
     */
    func startLoading(completion: @escaping ()->())
    
    /**
     Instructs the button to end loading with a given result
     - Parameter success: Indicates whether the button shall transform from loading to success or failing state
     - Parameter completion: A block to be called once the success or failure has been shown to the user (POST status block)
     */
    func endLoading(with success:Bool,completion: @escaping ()->())
    
    /// Instructs the view to expand itself again after being in a shrinked state. This will re show the title and hide the icon
    func expand()
    
    /**
     Instructs the button to shrink itself and sets an image if any
     - Parameter image: Will show this image inside the button if passed. Default is nil
     */
    func shrink(with image:UIImage?)
}

/// Represents the view model that controls the events and the look and feel for the Tap Action Button View
@objc open class TapActionButtonViewModel:NSObject {
    
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
    @objc public func startLoading(completion: @escaping ()->() = {}) {
        viewDelegate?.startLoading(completion: completion)
    }
    
    
    @objc public override init() {
        super.init()
        
        // Register for notifications to allow changing the status and the action block at run time form anywhere in the app
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TapConstantManager.TapActionSheetStatusNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TapConstantManager.TapActionSheetBlockNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StnNotificationExist(_:)), name: NSNotification.Name(rawValue: TapConstantManager.TapActionSheetStatusNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StnNotificationExist(_:)), name: NSNotification.Name(rawValue: TapConstantManager.TapActionSheetBlockNotification), object: nil)
    }
    
    /**
     Handles the logic needed to recieve the notifiations from other parts in the SDK to change the status and the action block of the button
     - Parameter notification: The recieved notification object from the dispatcher object
     */
    @objc func StnNotificationExist(_ notification:NSNotification)
    {
        // Let us decide if the notification is related to us, and if yes, let us decide its type and behave accordingly
        if notification.name.rawValue == TapConstantManager.TapActionSheetStatusNotification {
            // This is a notification to change the status of the button
            handleNewStatusNotification(with: notification)
        }else if notification.name.rawValue == TapConstantManager.TapActionSheetBlockNotification {
            // This is a notification to change the action handler of the button
            handleNewActionBlockNotification(with: notification)
        }
    }
    
    /**
     Handles the logic needed to recieve update button status notification
     - Parameter notification: The recieved notification object from the dispatcher object
     */
    internal func handleNewStatusNotification(with notification:NSNotification) {
        // Defensive code to make syre the dispatcher sent a correct button status
        if let status:TapActionButtonStatusEnum = notification.userInfo![TapConstantManager.TapActionSheetStatusNotification] as? TapActionButtonStatusEnum {
            // assign the new status
            self.buttonStatus = status
        }
    }
    
    /**
     Handles the logic needed to recieve update button action block notification
     - Parameter notification: The recieved notification object from the dispatcher object
     */
    internal func handleNewActionBlockNotification(with notification:NSNotification) {
        // Defensive code to make syre the dispatcher sent a correct action button block
        if let actionBlock:()->() = notification.userInfo![TapConstantManager.TapActionSheetBlockNotification] as? ()->() {
            // assign the new block
            self.buttonActionBlock = actionBlock
        }
    }
    
    /**
     Instructs the button to end loading with a given result
     - Parameter success: Indicates whether the button shall transform from loading to success or failing state
     - Parameter completion: A block to be called once the success or failure has been shown to the user (POST status block)
     */
    @objc public func endLoading(with success:Bool,completion: @escaping ()->() = {}) {
        viewDelegate?.endLoading(with: success, completion: completion)
    }
    
    /// Instructs the view to expand itself again after being in a shrinked state. This will re show the title and hide the icon
    @objc public func expandButton() {
        viewDelegate?.expand()
    }
    
    
    
    
    /// A protocol to communicate with the view controller with this view model
    internal var viewDelegate:TapActionButtonViewDelegate?
    
    
    /// Handles the logic needed when the status of the button changes
    internal func buttonStatusChanged() {
        // Inform the view, that he needs to reload itself based on the new status
        viewDelegate?.reload()
        if buttonStatus.shouldAutoShrink() {
            viewDelegate?.shrink(with: buttonStatus.authenticationIcons())
        }
    }
    
    /// Handles the logic needed when the action button is clicked, this will be fired from the view itself
    internal func didClickButton() {
        // perform the latest action block defined from the parent caller
        buttonActionBlock()
    }
}
