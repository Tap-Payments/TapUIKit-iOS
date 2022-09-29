//
//  PoweredByTapView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/09/2022.
//

import UIKit
import TapThemeManager2020

/// Represents the power by tap view
@objc public class PoweredByTapView: UIView {
    /// Represents the main holding view
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var poweredbyLabel: UILabel!
    @IBOutlet weak var tapLogo: UIImageView!
    internal let themePath:String = "poweredByTap"
    // Mark:- Init methods
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
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
}




// Mark:- Theme methods
extension PoweredByTapView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        poweredbyLabel.tap_theme_font = .init(stringLiteral: "\(themePath).powerLabel.font")
        poweredbyLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).powerLabel.textColor")
        
        tapLogo.image = TapThemeManager.imageValue(for: "\(themePath).tapLogo")
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
