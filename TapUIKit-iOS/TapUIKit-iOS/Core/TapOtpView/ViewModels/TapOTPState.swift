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

@objc public enum TapOTPState: Int {
    case empty
    case invalid
    case ready
    case expired
    
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

