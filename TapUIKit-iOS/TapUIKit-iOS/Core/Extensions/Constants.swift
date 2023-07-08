//
//  Constants.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import struct UIKit.CGFloat
import class UIKit.UIScreen

public class TapConstantManager {
    
    static let TapBottomSheetContainerTag:Int = 100
    static let TapBottomSheetMinimumHeight:CGFloat = 150
    static let TapBottomSheetMinimumYPoint:CGFloat = 35
    public static let TapActionSheetStatusNotification:String = "ActionButtonStatusChanged"
    public static let TapActionSheetBlockNotification:String = "ActionButtonBlockChanged"
    public static let TapBackButtonVisibilityNotification:String = "TapBackButtonVisibilityNotification"
    public static let TapBackButtonBlockNotification:String = "TapBackButtonBlockNotification"
    
    public static let TapAnimationDuration:Double = 0.75
    
    static var maxAllowedHeight:CGFloat {
        return UIScreen.main.bounds.height - (TapBottomSheetMinimumYPoint * 1)
    }
    
}
