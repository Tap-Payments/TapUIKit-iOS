//
//  ViewControllerTooltip.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 31/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

/// Class to controls the Tooltip
internal class TooltipController: Tooltip {
    /// View to be shown from
    var view: UIView
    /// Arrow direction
    var direction: TooltipDirection
    /// View to be shown
    var viewToShow: UIView
    /// View to be shown height
    var height: CGFloat
    /// View to be shown width
    var width: CGFloat
    /// Current App language
    var language: String
    
    
    init(view: UIView, direction: TooltipDirection, viewToShow: UIView, height: CGFloat, width: CGFloat, language: String) {
        self.view = view
        self.direction = direction
        self.language = language
        self.viewToShow = viewToShow
        self.height = height
        self.width = width
    }
    
}


