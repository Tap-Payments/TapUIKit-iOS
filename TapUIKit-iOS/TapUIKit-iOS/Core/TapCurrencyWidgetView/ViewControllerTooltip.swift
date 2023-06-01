//
//  ViewControllerTooltip.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

import UIKit

class TooltipController: Tooltip {
   
    
    
    init(view: UIView, direction: TooltipDirection, viewToShow: UIView, height: CGFloat, width: CGFloat) {
        self.view = view
        self.direction = direction
        self.key = "ds"
        self.viewToShow = viewToShow
        self.height = height
        self.width = width
    }
    var key: String
    
    var view: UIView
    
    var direction: TooltipDirection
    
    var viewToShow: UIView
    
    var height: CGFloat
    
    var width: CGFloat
    
    
}



