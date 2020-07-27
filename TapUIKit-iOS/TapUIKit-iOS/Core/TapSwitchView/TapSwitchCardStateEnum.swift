//
//  TapSwitchCardStateEnum.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/27/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

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
}
