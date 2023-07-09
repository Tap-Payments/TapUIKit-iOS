//
//  TapActionButtonViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import UIKit
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS
import TapThemeManager2020
/// A protocol to communicate between the owner with this view model
@objc public protocol TapActionButtonViewModelDelegate {
    /// Fired whenever the button started loading state
    @objc func didStartLoading()
    /// Fired whenever the button ended the loading
    @objc func didEndLoading()
}

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
    
    /// Tells the button to send back his own frame details
    func buttonFrame() -> CGRect
}

/// Represents the view model that controls the events and the look and feel for the Tap Action Button View
@objc open class TapActionButtonViewModel:NSObject {
    
    /// Represents the status of the action button
    @objc public var buttonStatus:TapActionButtonStatusEnum = .InvalidPayment{
        didSet{
            buttonStatusChanged()
        }
    }
    
    /// A protocol to communicate between the owner with this view model
    @objc public var delegate:TapActionButtonViewModelDelegate?
    
    /// The style to be applied to the button whenever it is in the valid state
    public var buttonStyle:PaymentOptionButtonStyle?
    
    /// A block representing the action to be executed when the button is clicked, please assign this accordignly based on the latest action required/fied from the main checkout screen
    @objc public var buttonActionBlock:()->() = {}
    
    /** Instructs the button view to start with the loading animation
     - Parameter completion: A block to be called once the collapsing is done
     */
    @objc public func startLoading(completion: @escaping ()->() = {}) {
        viewDelegate?.startLoading(completion: completion)
    }
    
    /// Add this custom string to be displayed beside the main title of the button. for example Pay FOR TAP PAYMENTS
    @objc public var appendCustomTitle:String = "" {
        didSet{
            if oldValue != appendCustomTitle {
                viewDelegate?.reload()
            }
        }
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
     Computes the correct title to be displayed within the pay button
     - returns: The correct displaying title given the current button status and if there is any custom string to append if passed by the owner
     */
    internal func buttonDisplayTitle() -> String {
        // The base title given the status
        var buttonTitle:String = buttonStatus.buttonTitle()
        // Only in case of charge or authorize we consider the custom string
        if buttonStatus == .InvalidPayment || buttonStatus == .ValidPayment {
            buttonTitle = "\(buttonTitle) \(appendCustomTitle)"
        }
        return buttonTitle
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
    
    /// Comutes the color of the action button based on its current status
    internal func backgroundColor() -> UIColor {
        return buttonStatus == .ValidPayment ? validPaymentButtonBackgroundColor() : buttonStatus.buttonBackGroundColor()
    }
    
    /// Comutes the solid color of the action button to show in loading state based on its current status
    internal func loadingShrinkingBackgroundColor() -> UIColor {
        
        // Check if we have a style passed first
        guard let buttonStyle:PaymentOptionButtonStyle = buttonStyle,
              buttonStatus == .ValidPayment,
              let solidColor:UIColor = buttonStyle.loadingBasebackgroundColor(showMonoForLightMode: TapThemeManager.showMonoForLightMode, showColoredForDarkMode: TapThemeManager.showColoredForDarkMode) else { return buttonStatus.buttonBackGroundColor() }
        
        return solidColor
    }
    
    /// Generates the correct loader image on the action button based on light and dark and mono
    internal func gifImageName() -> String {
        var computedGifName:String = TapThemeManager.stringValue(for: "actionButton.Common.assets.loading") ?? "Black-loader"
        if #available(iOS 12.0, *) {
            if UIView().traitCollection.userInterfaceStyle == .dark && TapThemeManager.showColoredForDarkMode {
                computedGifName = "3sec-white-loader-2"
            }else if UIView().traitCollection.userInterfaceStyle == .light && TapThemeManager.showMonoForLightMode {
                computedGifName = "3sec-white-loader-2"
            }
        }
        return computedGifName
    }
    
    
    /// Generates the correct success image on the action button based on light and dark and mono
    internal func successImageName() -> String {
        var computedGifName:String = TapThemeManager.stringValue(for: "actionButton.Common.assets.success") ?? "Black-loader"
        if #available(iOS 12.0, *) {
            if UIView().traitCollection.userInterfaceStyle == .dark && TapThemeManager.showColoredForDarkMode {
                computedGifName = "white-success-mob"
            }else if UIView().traitCollection.userInterfaceStyle == .light && TapThemeManager.showMonoForLightMode {
                computedGifName = "white-success-mob"
            }
        }
        return computedGifName
    }
    
    
    /// Generates the correct error image on the action button based on light and dark and mono
    internal func errorImageName() -> String {
        var computedGifName:String = TapThemeManager.stringValue(for: "actionButton.Common.assets.error") ?? "Black-loader"
        if #available(iOS 12.0, *) {
            if UIView().traitCollection.userInterfaceStyle == .dark && TapThemeManager.showColoredForDarkMode {
                computedGifName = "white-error-mob"
            }else if UIView().traitCollection.userInterfaceStyle == .light && TapThemeManager.showMonoForLightMode {
                computedGifName = "white-error-mob"
            }
        }
        return computedGifName
    }
    
    /// Only in valid payments statuses we will have to check if we shall return the default or the passed style by the caller if any
    /// If there is a passed style, it will create a color out of it but if not it will send the default valid payment color fetched from the theme file
    internal func validPaymentButtonBackgroundColor() -> UIColor {
        // Check if we have a style passed first
        guard let buttonStyle:PaymentOptionButtonStyle = buttonStyle, buttonStatus == .ValidPayment else { return buttonStatus.buttonBackGroundColor() }
        
        let backgroundColors:[UIColor] = buttonStyle.backgroundColors(showMonoForLightMode: TapThemeManager.showMonoForLightMode, showColoredForDarkMode: TapThemeManager.showColoredForDarkMode)
        
        // If passed, let us create a color outof it
        if backgroundColors.count > 1 {
            // Then we have a gradient colors to apply
            return UIColor.fromGradient(.init(direction: TapLocalisationManager.shared.localisationLocale == "ar" ? .leftToRight : .rightToLeft, colors: buttonStyle.backgroundColors(showMonoForLightMode: TapThemeManager.showMonoForLightMode, showColoredForDarkMode: TapThemeManager.showColoredForDarkMode)), frame: viewDelegate!.buttonFrame()) ?? .black
        }else{
            guard let nonNullColor:UIColor = backgroundColors.first else { return buttonStatus.buttonBackGroundColor() }
            return nonNullColor
        }
    }
    
    /**
     Decides whether or not we shall display an image as a title inside the action  button.
     Depends on the current status is VALID and there is a custom style passed from the caller
     That contains valid url to be displayed
     */
    internal func paymentTitleImage() -> (Bool, URL?) {
        // Compute the needed data for getting the correct URL
        // Now let us see what will we get, based on locale and display mode
        var displayModePath:String = TapThemeManager.showMonoForLightMode ? "light_mono" : "light"
        if #available(iOS 12.0, *) {
            displayModePath = (UIView().traitCollection.userInterfaceStyle == .dark) ? TapThemeManager.showColoredForDarkMode ? "dark_colored" : "dark" : TapThemeManager.showMonoForLightMode ? "light_mono" : "light"
        }
        // Now let us compute the path based on the locale
        let localePath:String = "\(TapLocalisationManager.shared.localisationLocale ?? "en")"
        
        // Check if we have a style passed first,
        // Then there is a valid url to load
        guard let buttonStyle:PaymentOptionButtonStyle = buttonStyle,
              buttonStatus == .ValidPayment,
              let _ = buttonStyle.titlesAssets,
              let finalURL:URL = URL(string:buttonStyle.paymentOptionImageUrl(for: displayModePath, and: localePath, with: ".png")),
              UIApplication.shared.canOpenURL(finalURL)
        else { return (false, nil) }
        
        return (true, finalURL)
        
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
        delegate?.didEndLoading()
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
