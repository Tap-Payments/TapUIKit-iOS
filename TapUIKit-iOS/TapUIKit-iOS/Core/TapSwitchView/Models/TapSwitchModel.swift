//
//  TapSwitchModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import LocalisationManagerKit_iOS

/// Tap switch model to represent the switch layer
public class TapSwitchModel: NSObject {
    /// Switch title text
    internal let title: String
    /// Switch subtitle text
    internal let subtitle: String
    /// notes message text
    internal let notes: String
    /// is switch state is on, default state is off
    internal var isOn: Bool
    
    public init(title: String, subtitle: String, isOn: Bool = false, notes: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.isOn = isOn
    }
    
    public init(localisedSwitchKey: String, isOn: Bool = false) {
        let sharedLocalisationManager:TapLocalisationManager = .shared

        self.title = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).title", with: TapCommonConstants.pathForDefaultLocalisation())
        self.subtitle = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).subtitle", with: TapCommonConstants.pathForDefaultLocalisation())
        self.notes = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).notes", with: TapCommonConstants.pathForDefaultLocalisation())
        self.isOn = isOn
    }
}
