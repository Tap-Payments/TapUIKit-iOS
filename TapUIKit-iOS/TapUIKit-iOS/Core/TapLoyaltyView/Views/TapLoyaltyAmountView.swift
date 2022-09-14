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
    /// The title label
    @IBOutlet weak var titleLabel: UILabel!
    /// list of views that needs to be forceable RTL support if needed
    @IBOutlet var toBeLocalisedViews: [UIView]!
    /// Displays how many points will the user redeem
    @IBOutlet weak var pointsLabel: UILabel!
    /// Allows the user to type in a specific amount he wants to redeem
    @IBOutlet weak var amountTextField: UITextField!
    /// Displays the currently being used currency
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var tapSeparator: TapSeparatorView!
    /// The path to look for theme entry in
    private let themePath = "loyaltyView.amountView"
    
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
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleFont")
        titleLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).titleTextColor")
        
        pointsLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont")
        pointsLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        currencyLabel.tap_theme_font = .init(stringLiteral: "\(themePath).currencyFont")
        currencyLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).currencyTextColor")
        
        amountTextField.tap_theme_font = .init(stringLiteral: "\(themePath).amountFont")
        amountTextField.tap_theme_textColor = .init(stringLiteral: "\(themePath).amountTextColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
