//
//  TapSeparatorView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
/// A custom UIView that shows a separator between different cells/lines/sections, Theme path : "tapSeparationLine"
public class TapSeparatorView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The view that represents the separation line we need to draw
    @IBOutlet var separationLine: UIView!
    /// The trailing constraint of the separation line, to be used in animating the width of the line
    @IBOutlet weak var separationLineTrailingConstraint: NSLayoutConstraint!
    /// The leadin constraint of the separation line, to be used in animating the width of the line
    @IBOutlet weak var separationLineLeadingConstraint: NSLayoutConstraint!
    /// The height constraint of the separation line, to be used to set the line height as per the theme
    @IBOutlet weak var separationLineHeightConstraint: NSLayoutConstraint!
    /// The path to look for theme entry in
    private let themePath = "tapSeparationLine"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        separationLine.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
}

// Mark:- Theme methods
extension TapSeparatorView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        separationLine.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        separationLineHeightConstraint.constant = CGFloat(TapThemeManager.numberValue(for: "\(themePath).height")?.floatValue ?? 1)
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
