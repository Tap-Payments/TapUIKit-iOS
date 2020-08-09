//
//  TapSwitchModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
/// Tap switch model to represent the switch layer
@objc public class TapSwitchModel: NSObject {
    /// Represents switch title text
    internal var title: String
    /// Represents switch subtitle text
    internal var subtitle: String
    /// Represents switch notes message text
    internal var notes: String
    /// Represents default tap localisation manager
    let sharedLocalisationManager:TapLocalisationManager = .shared
    /// is switch state is on, default state is off
    internal var isOn: Bool
    
    @objc public init(title: String, subtitle: String, isOn: Bool = false, notes: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.isOn = isOn
    }
    
    /**
     Create a model with the provided localised switch key
     - Parameter localisedSwitchKey:
     - Parameter isOn: Is the switch is on. default is false
     - Parameter merchant: The merchant name
     */
    @objc public init(localisedSwitchKey: String, isOn: Bool = false, merchant: String? = nil) {

        self.title = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).title", with: TapCommonConstants.pathForDefaultLocalisation())
        if let merchant = merchant {
            self.title = String(format: self.title, merchant)
        }
        self.subtitle = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).subtitle", with: TapCommonConstants.pathForDefaultLocalisation())
        self.notes = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).notes", with: TapCommonConstants.pathForDefaultLocalisation())
        self.isOn = isOn
    }
    
    /**
     Updates the title, subtitle and merchant text using the localised switch key
     - Parameter localisedSwitchKey: The localsied switch key to read from the theme manager
     - Parameter merchant: The merchant name
     */
    internal func update(localisedSwitchKey: String, merchant: String? = nil) {
        self.title = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).title", with: TapCommonConstants.pathForDefaultLocalisation())
        if let merchant = merchant {
            self.title = String(format: self.title, merchant)
        }
        
        self.subtitle = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).subtitle", with: TapCommonConstants.pathForDefaultLocalisation())
        self.notes = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).notes", with: TapCommonConstants.pathForDefaultLocalisation())
    }
}
