//
//  TapActionButtonStatusEnum.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// Represents the different statuses for the tap button action statuses, defining the context, localisation and theming
@objc public enum TapActionButtonStatusEnum:Int {
    
    /// Where we need to show a grey background with the titl PAY
    case InvalidPayment
    /// Where we need to show a green background with the titl PAY
    case ValidPayment
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
    
}
