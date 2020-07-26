//
//  TapSwitchEnum.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// Enum to define different statuses for switch view, providing info about each different status
@objc public enum TapSwitchEnum: Int {
    /// all switches are off
    case none
    /// all switches are on
    case all
    /// only goPay is switched on
    case goPay
    /// only merchant is switched on
    case merchant
}
