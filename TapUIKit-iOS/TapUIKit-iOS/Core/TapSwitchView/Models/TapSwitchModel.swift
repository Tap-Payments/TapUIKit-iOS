//
//  TapSwitchModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public class TapSwitchModel: NSObject {
    public let title: String
    public let subtitle: String
    public var isOn: Bool
    
    public init(title: String, subtitle: String, isOn: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
    }
}
