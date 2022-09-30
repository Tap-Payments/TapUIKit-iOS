//
//  TapInternalSaveCard.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 30/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//


import UIKit
import TapThemeManager2020
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS
import EasyTipView

/// Represents the save card for tap for later view
@objc public class TapInternalSaveCard: UIView {
    /// Represents the main holding view
    @IBOutlet var containerView: UIView!
    /// Representing the title label
    @IBOutlet weak var saveCardLabel: UILabel!
    /// The checkbox view where the user can decide whether he wants to save teh card or not
    @IBOutlet weak var saveCardButton: UIImageView!
    /// The info button to tell the user the info needed to know about saving a card process
    @IBOutlet weak var saveInfoButton: UIImageView!
    /// A delegate to listen to events fired from the save card view
    @objc public var delegate:TapSaveCardViewDelegate?
    /// Indicates whether or not the user checked the save card for Tap box
    internal var isSavedCardEnabled:Bool = true {
        didSet{
            if oldValue != isSavedCardEnabled {
                handleSaveCardForTapChanged()
            }
        }
    }
    
    internal let themePath:String = "inlineCard.saveCardForTapOption"
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Handler for clicking in the checkboc for saving the card for TAP
    internal func saveCardButtonClicked() {
        // toggle the enablity of the checkbox
        isSavedCardEnabled = !isSavedCardEnabled
    }
    
    /// Handler for clicking on save info button
    internal func saveInfoButtonClicked() {
        // first of all, disable the info button so the user cannot show duplicates of the tooltip
        saveInfoButton.isUserInteractionEnabled = false
        // Theme the tool tip, localise it and show it :)
        EasyTipView.show(forView: saveInfoButton,
                         withinSuperview: self.superview,
                         text: TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveForTapInfo", with: TapCommonConstants.pathForDefaultLocalisation()),
                         preferences: themeSaveCardToolTip(),
                         delegate: self)
    }
    
    /// Generates the right theme for the tooltip
    internal func themeSaveCardToolTip() -> EasyTipView.Preferences {
        var preferences = EasyTipView.Preferences()
        
        preferences.drawing.font = TapThemeManager.fontValue(for: "\(themePath).labelTextFont",shouldLocalise: true) ?? .systemFont(ofSize: 20, weight: .light)
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = .black
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        preferences.positioning.maxWidth = 250
        
        return preferences
    }
    
    /// Handles the post logic required after the user enables/disables the save card for tap checkbox
    internal func handleSaveCardForTapChanged() {
        // Update the UI of the checkbox
        saveCardButton.tap_theme_tintColor = ThemeUIColorSelector.init(keyPath: isSavedCardEnabled ? "\(themePath).saveButtonActivatedTintColor" : "\(themePath).saveButtonDeactivatedTintColor")
        // Inform the delegate
        delegate?.saveCardChanged(for: .Tap, to: isSavedCardEnabled)
    }
    
    /// Handles the tapping events on different UIImageViews inside the view
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
        
        if tappedImage == saveCardButton {
            saveCardButtonClicked()
        }else if tappedImage == saveInfoButton{
            saveInfoButtonClicked()
        }
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        saveCardLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        addTapRecognizer(for: saveCardButton)
        addTapRecognizer(for: saveInfoButton)
        applyTheme()
    }
    
    /// Adds a tap recognizer for a provided image view
    internal func addTapRecognizer(for imageView:UIImageView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
}




// Mark:- Theme methods
extension TapInternalSaveCard {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        localize()
    }
    
    /// Fetches the correct localized labels and titles
    private func localize() {
        saveCardLabel.text = TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveForTapLabel", with: TapCommonConstants.pathForDefaultLocalisation())
        saveCardLabel.translatesAutoresizingMaskIntoConstraints = false
        if TapLocalisationManager.shared.localisationLocale == "ar" {
            saveCardLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(saveCardButton.snp.centerY).offset(10)
            }
            saveCardLabel.layoutIfNeeded()
            layoutIfNeeded()
        }
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        
        // Theme the save card label
        saveCardLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelTextFont")
        saveCardLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelTextColor")
        
        // Theme teh save card buttons
        saveCardButton.tap_theme_tintColor = ThemeUIColorSelector.init(keyPath: isSavedCardEnabled ? "\(themePath).saveButtonActivatedTintColor" : "\(themePath).saveButtonDeactivatedTintColor")
        saveInfoButton.tap_theme_tintColor = ThemeUIColorSelector.init(keyPath: "\(themePath).infoButtonTintColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


extension TapInternalSaveCard : EasyTipViewDelegate {
    public func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        // Enable the info tooltip button again
        saveInfoButton.isUserInteractionEnabled = true
    }
    
    
}
