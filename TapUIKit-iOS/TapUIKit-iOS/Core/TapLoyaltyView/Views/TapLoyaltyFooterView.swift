//
//  TapLoyaltyFooterView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 15/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import TapThemeManager2020

/// Represents the footer sub view in the loyalty widget
internal class TapLoyaltyFooterView: UIView {
    /// The container view that holds everything from the XIB
    @IBOutlet var conentView: UIView!
    /// Displays the remaining points after redemeption
    @IBOutlet weak var remainingPointsLabel: UILabel!
    /// Displayss the name of the points in this loyalty program
    @IBOutlet weak var pointsNameLabel: UILabel!
    ////// Displays the remaining points after redemeption
    @IBOutlet weak var remaningPointsCountLabel: UILabel!
    /// Displays the amount remaining to pay after redemption
    @IBOutlet weak var remainingAmountLabel: UILabel!
    /// The current selected currency data
    internal var viewModel:TapLoyaltyViewModel?
    /// The path to look for theme entry in
    private let themePath = "loyaltyView.footerView"
    
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
        self.conentView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    /**
     Will stup the content of the view with the given data
     - Parameter with viewModel: The view mdoel
     */
    internal func setup(with viewModel:TapLoyaltyViewModel) {
        // save the viewModel
        self.viewModel = viewModel
        reloadData()
    }
    
    /// Set the textual contents based on latest values in the view model
    internal func reloadData() {
        remainingPointsLabel.text = viewModel?.pointsRemaningText
        pointsNameLabel.text = viewModel?.pointsNameText
        remaningPointsCountLabel.text = viewModel?.remainingPoints
        remainingAmountLabel.text = viewModel?.amountRemaningText
    }
    
}



extension TapLoyaltyFooterView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        conentView.backgroundColor = .clear
        
        remainingPointsLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont")
        remainingPointsLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        pointsNameLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont")
        pointsNameLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        remaningPointsCountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont")
        remaningPointsCountLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        remainingAmountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).amountFont")
        remainingAmountLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).amountTextColor")
        
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
