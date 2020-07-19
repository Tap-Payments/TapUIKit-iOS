//
//  TapOTPState.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import UIKit
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants

/// Enum to define different states for otp view, providing info about each different status
@objc public enum TapOTPStateEnum: Int {
    /// Initial case when otp digits are not filled completely or empty
    case empty
    /// invalid when otp digits are filled with wrong digits
    case invalid
    /// ready state when otp is filled completely and ready to be validated
    case ready
    /// expired case when otp timer is finished
    case expired
    
    /// This method returns formatted message for each state
    /// - Parameters:
    ///   - mobileNo: mobile number to be shown in the state message
    ///   - mainColor: default text color to be used in the formatted text
    ///   - secondaryColor: second text color to be set for the mobile number text
    /// - Returns: return NSAttributedString contains the message and the mobile number depending on the current state
    func message(mobileNo: String = "", mainColor: UIColor, secondaryColor: UIColor) -> NSAttributedString {
        let firstAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: mainColor]

        let firstString = NSMutableAttributedString(string: "\(self.localizedTitle(localized: true)) ", attributes: firstAttributes)
        if !mobileNo.isEmpty {
            let secondAttributes = [NSAttributedString.Key.foregroundColor: secondaryColor]
            let secondString = NSAttributedString(string: mobileNo, attributes: secondAttributes)
            firstString.append(secondString)
        }
        
        return firstString as NSAttributedString
    }
    
    /**
     The localization path of the localized value to show for each status
     - Parameter localized: If set, the method will return th localzed value otherwise, will return the localization path only
     - Returns: The actual localization path in the localization file or the localized value itself based on inptu
     */
    func localizedTitle(localized:Bool = false) -> String {
        let sharedLocalisationManager:TapLocalisationManager = .shared
        
        switch self {
        case .empty, .ready:
            return localized ? sharedLocalisationManager.localisedValue(for: "TapOtpView.Message.Ready", with: TapCommonConstants.pathForDefaultLocalisation()) : "TapOtpView.Message.Ready"
        case .invalid:
            return localized ? sharedLocalisationManager.localisedValue(for: "TapOtpView.Message.Invalid", with: TapCommonConstants.pathForDefaultLocalisation()) : "TapOtpView.Message.Invalid"
        case .expired:
            return localized ? sharedLocalisationManager.localisedValue(for: "TapOtpView.Message.Expired", with: TapCommonConstants.pathForDefaultLocalisation()) : "TapOtpView.Message.Expired"
        }
    }
    
    /**
     The theme path that has the UI info for each case
     - Returns: The actual theme path in the theme file that has the needed ui info for the given status
     */
    func themePath() -> String {
        switch self {
        case .ready,.empty:
            return "TapOtpView.Ready"
        case .invalid:
            return "TapOtpView.Invalid"
        case .expired:
            return "TapOtpView.Expired"
        }
    }
}

