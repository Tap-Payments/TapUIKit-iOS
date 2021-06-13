//
//  AmountMoficiationType.swift
//  CommonDataModelsKit-iOS
//
//  Created by Osama Rabie on 6/13/21.
//  Copyright © 2021 Tap Payments. All rights reserved.
//

import Foundation
/// Represent an enum to decide all the possible amount modifications types
@objc public enum AmountModificationType: Int,RawRepresentable,Encodable {
    /// Meaning, the modification will be a percentage of the item's price
    case Percentage = 1
    /// Meaning, the modification will be a fixed value to be deducted as is
    case Fixed = 2
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .Percentage:
            return "percentage"
        case .Fixed:
            return "fixed"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "percentage":
            self = .Percentage
        case "fixed":
            self = .Fixed
        default:
            return nil
        }
    }
}
