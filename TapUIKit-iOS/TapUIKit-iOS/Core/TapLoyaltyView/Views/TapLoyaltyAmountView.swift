//
//  TapLoyaltyAmountView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 14/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit

class TapLoyaltyAmountView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// list of views that needs to be forceable RTL support if needed
    @IBOutlet var toBeLocalisedViews: [UIView]!
    
    // MARK: Init methods
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
        translatesAutoresizingMaskIntoConstraints = false
        
        //toBeLocalisedViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
        applyTheme()
    }
}

extension TapLoyaltyAmountView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        //backgroundColor = .clear
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
