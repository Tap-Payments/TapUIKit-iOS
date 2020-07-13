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
@objc enum TapHintViewStatusEnum:Int {
    /// Warning case like invalid Expiry or invalid CVV
    case Warning = 1
    /// Error case like wrong card number
    case Error = 2
    /// Default case like ready to scan
    case Default = 3
    /// The successful scanner feedback hint
    case Scanned = 4
    
    /**
     The theme path that has the UI info for each case
     - Returns: The actual theme path in the theme file that has the needed ui info for the given status
     */
    func themePath() -> String {
        switch self {
        case .Warning:
            return "Hints.Warning"
        case .Error:
            return "Hints.Error"
        case .Default:
            return "Hints.Default"
        case .Scanned:
            return "Hints.Scanned"
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
        case .Warning:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Warning", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Warning"
        case .Error:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Error", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Error"
        case .Default:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Default", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Default"
        case .Scanned:
            return localized ? sharedLocalisationManager.localisedValue(for: "Hints.Scanned", with: TapCommonConstants.pathForDefaultLocalisation()) : "Hints.Scanned"
        }
    }
    
    
}
