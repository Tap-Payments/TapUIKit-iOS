//
//  TapSaveCardView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS

/// A delegate to listen to events fired from the save card view
@objc public protocol TapSaveCardViewDelegate {
    /**
     This method will be called whenever the user change the status of the save card option for merchant or TAP
     - Parameter for saveCard: Defines for which save card type the action was done. Merchant or TAP
     - Parameter to enabled: The new status
     */
    @objc func saveCardChanged(for saveCardType:SaveCardType,to enabled:Bool)
}

/// Represents the save card for later view
@objc public class TapSaveCardView: UIView {
    /// Represents the main holding view
    @IBOutlet var containerView: UIView!
    /// Representing the title label
    @IBOutlet weak var saveCardLabel: UILabel!
    /// The switch view where the user can decide whether he wants to save teh card or not
    @IBOutlet weak var saveCardSwitch: UISwitch!
    /// A delegate to listen to events fired from the save card view
    @objc public var delegate:TapSaveCardViewDelegate?
    
    internal let themePath:String = "inlineCard"
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @IBAction func saveCardSwitchChanged(_ sender: Any) {
        delegate?.saveCardChanged(for: .Merchant,to: saveCardSwitch.isOn)
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        saveCardLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
}




// Mark:- Theme methods
extension TapSaveCardView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        localize()
    }
    
    /// Fetches the correct localized labels and titles
    private func localize() {
        saveCardLabel.text = TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveLabel", with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        
        // Theme the save card label
        saveCardLabel.tap_theme_font = .init(stringLiteral: "\(themePath).saveCardOption.labelTextFont")
        saveCardLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).saveCardOption.labelTextColor")
        
        // Theme teh save card switch
        saveCardSwitch.tap_theme_tintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchTintColor")
        saveCardSwitch.tap_theme_thumbTintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchThumbColor")
        saveCardSwitch.tap_theme_onTintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).saveCardOption.switchOnThumbColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
