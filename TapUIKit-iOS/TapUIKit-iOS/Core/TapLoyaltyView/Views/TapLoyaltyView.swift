//
//  TapLoyaltyView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit

/// A view represents the loyalty points view used while paying
@objc public class TapLoyaltyView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    
    /// The actual container view that holds everything from the XIB
    @IBOutlet var cardView: UIView!
        
    /// The path to look for theme entry in
    private let themePath = "loyaltyView"
    
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
        translatesAutoresizingMaskIntoConstraints = false
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
}



// Mark:- Theme methods
extension TapLoyaltyView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        cardView.layer.cornerRadius = 20.0
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowRadius = 12.0
        cardView.layer.shadowOpacity = 0.7
        
        
        /*titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        titleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).titleLabelColor")
        
        subtitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).subTitleLabelFont")
        subtitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).subTitleLabelColor")
        
        merchantLogoContainerView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).merchantLogoCorner")
        merchantLogoPlaceHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderColor")
        merchantLogoPlaceHolderInitialLabel.tap_theme_font = .init(stringLiteral: "\(themePath).merchantLogoPlaceHolderFont")
        merchantLogoPlaceHolderInitialLabel.tap_theme_textColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderLabelColor")
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        // Push the title and the merchant header a bit if arabic is being used
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topSpaceBetweenMerchantNameAndTitleConstraint.constant += (TapLocalisationManager.shared.localisationLocale == "ar") ? 2 : 0*/
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
