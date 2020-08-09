//
//  TapSwitchCardStateEnum.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/27/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// Enum to define different statuses for switch view, providing info about each different status
@objc public enum TapSwitchCardStateEnum: Int {
    /// valid card case
    case validCard
    /// invalid card case
    case invalidCard
    /// valid telecom case
    case validTelecom
    /// invalid telecom case
    case invalidTelecom
    
    /**
     Get the main localised text depending on the current tap localisation
     - Returns: localised title text
     */
    func mainLocalisedTitle() -> String {
        let sharedLocalisationManager:TapLocalisationManager = .shared

        switch self {
        case .validCard:
            return sharedLocalisationManager.localisedValue(for: "TapSwitchView.mainCards.titleValid", with: TapCommonConstants.pathForDefaultLocalisation())
        case .invalidCard:
            return sharedLocalisationManager.localisedValue(for: "TapSwitchView.mainCards.titleEmpty", with: TapCommonConstants.pathForDefaultLocalisation())
        case .validTelecom:
            return sharedLocalisationManager.localisedValue(for: "TapSwitchView.mainTelecom.titleValid", with: TapCommonConstants.pathForDefaultLocalisation())
        case .invalidTelecom:
            return sharedLocalisationManager.localisedValue(for: "TapSwitchView.mainTelecom.titleEmpty", with: TapCommonConstants.pathForDefaultLocalisation())
        }
    }
}
