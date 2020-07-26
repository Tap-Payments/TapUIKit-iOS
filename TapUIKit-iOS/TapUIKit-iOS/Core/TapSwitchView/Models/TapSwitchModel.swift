//
//  TapSwitchModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

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
}
