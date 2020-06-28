//
//  TapCardPhoneIconView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

class TapCardPhoneIconView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The path to look for theme entry in
    private let themePath = "cardPhoneList.icon"
    
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
        self.contentView = setupXIB()
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
}



// Mark:- Theme methods
extension TapCardPhoneIconView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}

