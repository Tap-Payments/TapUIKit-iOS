//
//  TapChipCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation

/// This class is responsible for creating a viewmodel for feeding up the tap chip element/cell
@objc public class TapChipCellViewModel:TapCellViewModel {
    
    /// The left accessory uiimageview of the chip element
    internal var leftAccessory:TapChipAccessoryView?
    /// The right accessory uiimageview of the chip element
    internal var rightAccessory:TapChipAccessoryView?
    /// The content label of the chip element
    internal lazy var bodyContent:String = ""
    
    /**
        Creates a recent card view model to be used to draw data inside a recent card chip cell
    - Parameter leftAccessory: The left accessory uiimageview of the chip element. Default is nil
    - Parameter rightAccessory: The right accessory uiimageview of the chip element. Default is nil
    - Parameter bodyContent: The string content of the chip
     */
    @objc public convenience init(leftAccessory:TapChipAccessoryView? = nil, rightAccessory:TapChipAccessoryView? = nil, bodyContent:String = "") {
        self.init()
        self.leftAccessory = leftAccessory
        self.rightAccessory = rightAccessory
        self.bodyContent = bodyContent
    }
    
}
