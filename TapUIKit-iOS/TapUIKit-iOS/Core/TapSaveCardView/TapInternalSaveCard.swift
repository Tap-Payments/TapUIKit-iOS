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
import SnapKit

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
    internal var isSavedCardEnabled:Bool = false {
        didSet{
            if oldValue != isSavedCardEnabled {
                handleSaveCardForTapChanged()
            }
        }
    }
    /// The tooltip component to show info about saving a card for TAP
    internal var ev:EasyTipView?
    
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
        //ev = EasyTipView(text: TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveForTapInfo", with: TapCommonConstants.pathForDefaultLocalisation()), preferences: themeSaveCardToolTip(), delegate: self)
        //ev?.show(animated: true, forView: saveInfoButton, withinSuperview: self.superview)
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.backgroundColor = .clear
        
        preferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: 15)
        preferences.animating.showInitialAlpha = 0
        preferences.animating.showDuration = 1
        preferences.animating.dismissDuration = 1
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.cornerRadius = 8
        preferences.drawing.borderWidth = 1
        preferences.drawing.borderColor = TapThemeManager.colorValue(for: "\(themePath).tooltip.borderColor") ?? .clear
        preferences.positioning.bubbleInsets  = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
        preferences.positioning.contentInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        ev = EasyTipView(contentView: generateToolTipView(), preferences: preferences, delegate: self)
        ev?.show(animated: true, forView: saveInfoButton)
        
        /*EasyTipView.show(forView: self.saveInfoButton,
         contentView: generateToolTipView(),
         preferences: preferences,
         delegate: self)*/
    }
    
    
    internal func generateToolTipView() -> UIView {
        let tooltipView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 112))
        tooltipView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(frame: CGRect(x: 6, y: 6, width: 298, height: 110))
        blurView.effect = blurEffect
        blurView.layer.cornerRadius = 8
        blurView.clipsToBounds = true
        tooltipView.addSubview(blurView)
        
        // Add the title label
        let titleLabel:UILabel = .init()
        titleLabel.text = TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveForTapInfoTitle", with: TapCommonConstants.pathForDefaultLocalisation())
        titleLabel.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).tooltip.titleFont",shouldLocalise: true)
        titleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).tooltip.titleColor")
        tooltipView.addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(270)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(22)
        }
        
        titleLabel.layoutIfNeeded()
        
        
        // Add the message label
        let messageLabel:UILabel = .init()
        messageLabel.text = TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cardSaveForTapInfoMessage", with: TapCommonConstants.pathForDefaultLocalisation())
        messageLabel.numberOfLines = 6
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.sizeToFit()
        messageLabel.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).tooltip.subTitleFont",shouldLocalise: true)
        messageLabel.tap_theme_textColor = .init(keyPath: "\(themePath).tooltip.subTitleColor")
        tooltipView.addSubview(messageLabel)
        messageLabel.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(270)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(16)
        }
        messageLabel.layoutIfNeeded()
        if  TapLocalisationManager.shared.localisationLocale == "ar" {
            titleLabel.textAlignment = .right
            messageLabel.textAlignment = .right
        }
        return tooltipView
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
        // No image when unselected as per new UI requirements
        saveCardButton.image = isSavedCardEnabled ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square.fill")
        // Inform the delegate
        delegate?.saveCardChanged(for: .Tap, to: isSavedCardEnabled)
        ev?.dismiss()
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
        
        saveCardButton.image = isSavedCardEnabled ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square.fill")
        
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
