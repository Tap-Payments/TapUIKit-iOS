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
public class TapSwitchModel: NSObject {
    /// Switch title text
    internal var title: String
    /// Switch subtitle text
    internal var subtitle: String
    /// notes message text
    internal var notes: String
    /// is switch state is on, default state is off
    
    let sharedLocalisationManager:TapLocalisationManager = .shared
    
    internal var isOn: Bool
    
    public init(title: String, subtitle: String, isOn: Bool = false, notes: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.isOn = isOn
    }
    
    public init(localisedSwitchKey: String, isOn: Bool = false, merchant: String? = nil) {

        self.title = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).title", with: TapCommonConstants.pathForDefaultLocalisation())
        if let merchant = merchant {
            self.title = String(format: self.title, merchant)
        }
        self.subtitle = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).subtitle", with: TapCommonConstants.pathForDefaultLocalisation())
        self.notes = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).notes", with: TapCommonConstants.pathForDefaultLocalisation())
        self.isOn = isOn
    }
    
    internal func update(localisedSwitchKey: String, merchant: String? = nil) {
        self.title = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).title", with: TapCommonConstants.pathForDefaultLocalisation())
        if let merchant = merchant {
            self.title = String(format: self.title, merchant)
        }
        
        self.subtitle = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).subtitle", with: TapCommonConstants.pathForDefaultLocalisation())
        self.notes = sharedLocalisationManager.localisedValue(for: "TapSwitchView.\(localisedSwitchKey).notes", with: TapCommonConstants.pathForDefaultLocalisation())
    }
}
