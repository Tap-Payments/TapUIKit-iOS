//
//  TapSwitchModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public class TapSwitchModel: NSObject {
    internal let title: String
    internal let subtitle: String
    internal let notes: String
    internal var isOn: Bool
    
    public init(title: String, subtitle: String, isOn: Bool = false, notes: String = "") {
        self.title = title
        self.subtitle = subtitle
        self.notes = notes
        self.isOn = isOn
    }
}