//
//  TapActionButtonStatusEnum.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants

/// Represents the different statuses for the tap button action statuses, defining the context, localisation and theming
@objc public enum TapActionButtonStatusEnum:Int {
    
    /// Where we need to show a grey background with the titl PAY
    case InvalidPayment
    /// Where we need to show a green background with the titl PAY
    case ValidPayment
    /// Where we need to show a green background with the titl PAY and the user is opening the save card switches
    case SaveValidPayment
    /// Where we need to show a grey background with the titl confirm
    case InvalidConfirm
    /// Where we need to show a blue background with the titl confirm
    case ValidConfirm
    /// Where we need to show a blue background with the titl Resend OTP
    case ResendOTP
    /// Where we need to show a grey background with the titl Signin
    case InvalidSignIn
    /// Where we need to show a blue background with the titl Signin
    case ValidSignIn
    /// Where we need to show a grey background with the titl next
    case InvalidNext
    /// Where we need to show a blue background with the titl Signin
    case ValidNext
    
    
    /**
     Decides the color of the action button based on its current status
     - Returns: The correct color from the theme manager file based on the given status
     */
    public func buttonBackGroundColor() -> UIColor {
        
        var backgroundThemePath:String = ""
        
        switch self {
        case .InvalidPayment,.InvalidNext,.InvalidSignIn,.InvalidConfirm:
            backgroundThemePath = "actionButton.Invalid.backgroundColor"
            break
        case .ValidPayment,.SaveValidPayment:
            backgroundThemePath = "actionButton.Valid.paymentBackgroundColor"
            break
        case .ValidConfirm,.ResendOTP,.ValidSignIn,.ValidNext:
            backgroundThemePath = "actionButton.Valid.goLoginBackgroundColor"
            break
        }
        return TapThemeManager.colorValue(for: backgroundThemePath) ?? .clear
    }
    
    
    /**
     Decides the color of the holder view background color of the action button
     - Returns: The correct holder view background color from the theme manager file based on the given status
     */
    public func buttonViewBackGroundColor() -> UIColor {
        
        var backgroundThemePath:String = ""
        
        switch self {
            // These cases we need to have a clear background to show the blur background
        case .SaveValidPayment,.InvalidConfirm,.ValidConfirm,.ResendOTP,.InvalidSignIn,.ValidSignIn:
            backgroundThemePath = "actionButton.BackgroundColor.Otp"
            break
        default:
            // These cases we need to have a white two background color
            backgroundThemePath = "actionButton.BackgroundColor.default"
            break
        }
        return TapThemeManager.colorValue(for: backgroundThemePath) ?? .clear
    }
    
    
    /**
     Decides the title of the tap action button based on the status
     - Returns: The correct title of the tap action button basde on the given status
     */
    public func buttonTitle() -> String {
        let sharedLocalisationManager:TapLocalisationManager = .shared
       
        var localizedTitle:String = ""
        
        switch self {
        case .InvalidSignIn,.ValidSignIn:
            // These cases we need to have a SignIn title
            localizedTitle = sharedLocalisationManager.localisedValue(for: "ActionButton.signin", with: TapCommonConstants.pathForDefaultLocalisation())
            break
        case .ValidConfirm,.InvalidConfirm:
            // These cases we need to have a Confitm title
            localizedTitle = sharedLocalisationManager.localisedValue(for: "ActionButton.confirm", with: TapCommonConstants.pathForDefaultLocalisation())
            break
        case .ResendOTP:
            // These cases we need to have a ResendOTP title
            localizedTitle = sharedLocalisationManager.localisedValue(for: "ActionButton.resend", with: TapCommonConstants.pathForDefaultLocalisation())
            break
        case .InvalidNext,.ValidNext:
            // These cases we need to have a Next title
            localizedTitle = sharedLocalisationManager.localisedValue(for: "ActionButton.next", with: TapCommonConstants.pathForDefaultLocalisation())
            break
        default:
            // These cases we need to have a PAY title
            localizedTitle = sharedLocalisationManager.localisedValue(for: "ActionButton.pay", with: TapCommonConstants.pathForDefaultLocalisation())
            break
        }
        return localizedTitle
    }
    
    
}
