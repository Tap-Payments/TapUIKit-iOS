//
//  TapHintViewStatusEnum.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants

/// Enum to define different statuses for hint view, providing info about each different status
@objc public enum TapHintViewStatusEnum:Int {
    /// Warning case missing CVV
    case WarningCVV = 1
    /// Warning case missing CVV and Expiry
    case WarningExpiryCVV = 2
    /// Error case wrong card number
    case ErrorCardNumber = 3
    /// Ready to scan
    case ReadyToScan = 4
    /// The successful scanner feedback hint
    case Scanned = 5
    /// The feedback anout the email to use the password to
    case GoPayPassword = 6
    /// The feedback aout the number the OTP sent to
    case GoPayOtp = 7
    /// The fsaved card case the number the OTP sent to
    case SavedCardOTP = 8
    /// No hint should be shown
    case None = 9
    /// No hint should be shown
    case Error = 10
    /// Warning case missing name
    case WarningName = 11
    
    /**
     The theme path that has the UI info for each case
     - Returns: The actual theme path in the theme file that has the needed ui info for the given status
     */
    func themePath() -> String {
        switch self {
        case .WarningCVV,.WarningExpiryCVV,.WarningName:
            return "Hints.Warning"
        case .ErrorCardNumber:
            return "Hints.Error"
        case .ReadyToScan:
            return "Hints.Default"
        case .Scanned:
            return "Hints.Scanned"
        case .GoPayOtp,.GoPayPassword,.SavedCardOTP:
            return "Hints.GoPayLogin"
        default:
            return ""
        }
    }
    
    /**
     The localization path of the localized value to show for each status
     - Parameter localized: If set, the method will return th localzed value otherwise, will return the localization path only
     - Returns: The actual localization path in the localization file or the localized value itself based on inptu
     */
    func localizedTitle(localized:Bool = false) -> String {
        let sharedLocalisationManager:TapLocalisationManager = .shared
        
        switch self {
        case .WarningExpiryCVV:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Warning.missingExpiryCVV", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Warning.missingExpiryCVV"
        case .WarningCVV:
            return localized ? String(format: sharedLocalisationManager.localisedValue(for: "Hints.Warning.missingCVV", with: TapCommonConstants.pathForDefaultLocalisation()), 3) : "Hints.Warning.missingCVV"
        case .WarningName:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Warning.missingName", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Warning.missingName"
        case .ErrorCardNumber:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Error.wrongCardNumber", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Error.wrongCardNumber"
        case .ReadyToScan:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Default.scan", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Default.scan"
        case .Scanned:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Scanned.successFullScan", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Scanned.successFullScan"
        case .GoPayPassword:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.GoPayLogin.password", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.GoPayLogin.password"
        case .GoPayOtp,.SavedCardOTP:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.GoPayLogin.otp", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.GoPayLogin.otp"
        default:
            return ""
        }
    }
    
    /**
     Fetches the localized title of the action button
     - Returns: Change for OTP and Password and nothing otherwise
     */
    func localizedActionButtonTitle() -> String {
        let sharedLocalisationManager:TapLocalisationManager = .shared
        switch self {
        case .GoPayOtp,.GoPayPassword:
            return sharedLocalisationManager.localisedValue(for: "Common.change", with: TapCommonConstants.pathForDefaultLocalisation()).uppercased()
        default:
            return ""
        }
    }
    
    
    /**
     Determinse based on the status if the action sheet should be visible or not
     - Returns: True if it is an otp or password hint and false otherwise
     */
    func shouldShowActionButton() -> Bool {
        switch self {
        case .GoPayOtp,.GoPayPassword:
            return true
        default:
            return false
        }
    }
    
    
}
