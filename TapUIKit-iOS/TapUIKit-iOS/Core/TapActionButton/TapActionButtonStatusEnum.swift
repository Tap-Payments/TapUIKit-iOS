//
//  TapActionButtonStatusEnum.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
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
        case .SaveValidPayment,.InvalidConfirm,.ValidConfirm,.ResendOTP,.InvalidSignIn,.ValidSignIn:
            backgroundThemePath = "actionButton.BackgroundColor.Otp"
            break
        default:
            backgroundThemePath = "actionButton.BackgroundColor.default"
            break
        }
        return TapThemeManager.colorValue(for: backgroundThemePath) ?? .clear
    }
}
