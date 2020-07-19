//
//  TapActionButton.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

/// Represents the Tap Action Button View
@objc public class TapActionButton: UIView {

    /// the main holder view
    @IBOutlet weak var contentView: UIView!
    /// The image used to show the laoder, success and failure animations
    @IBOutlet weak var loaderGif: UIImageView!
    /// The view holder for the uibutton
    @IBOutlet weak var viewHolder: UIView!
    /// The button itself
    @IBOutlet weak var payButton: UIButton!
    /// The width of the view holder to perform the expansion/collapsing animations when needed
    @IBOutlet weak var viewHolderWidth: NSLayoutConstraint!

    
    @IBAction func tapActionButtonClicked(_ sender: Any) {
        
    }
    
}
