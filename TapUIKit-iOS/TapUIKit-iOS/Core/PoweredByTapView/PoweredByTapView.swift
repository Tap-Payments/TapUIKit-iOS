//
//  PoweredByTapView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/09/2022.
//

import UIKit
import TapThemeManager2020
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// Represents the power by tap view
@objc public class PoweredByTapView: UIView {
    /// The view holding the back button
    @IBOutlet weak var backView: UIView!
    /// The back indicator label
    @IBOutlet weak var backLabel: UIButton!
    /// Indicating the back icon for the user
    @IBOutlet weak var backIconImageView: UIImageView!
    /// Represents the main holding view
    @IBOutlet weak var cardBlur: CardVisualEffectView!
    /// The container view for the custom Xib
    @IBOutlet var containerView: UIView!
    /// The image view holding powered by tap logo
    @IBOutlet public weak var poweredByTapLogo: UIImageView!
    /// Holds the UIViews that needed to be RTL supported based on the selected locale
    @IBOutlet var toBeLocalizedViews: [UIView]!
    /// The action handler to fire when back button is clicked
    var backActionHandler:(()->())? = nil
    
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
        setContent()
        applyTheme()
        adjustDirections()
        setListeners()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    //MARK: - Private functions
    /// Sets the content for labels and flipped images for uiimageviews
    private func setContent() {
        // The localized back label
        backLabel.setTitle(TapLocalisationManager.shared.localisedValue(for: "Common.back",with: TapCommonConstants.pathForDefaultLocalisation()), for: .normal)
        // The correct back arrow, it should be flipped if we are in Arabic mode
        var backImageIcon:UIImage? = .init(systemName: "chevron.backward")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        backIconImageView.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        // Set the icon
        backIconImageView.image = backImageIcon?.withHorizontallyFlippedOrientation()
    }
    
    /// Will make the powered by tap view listen to the show/hide back button from anywhere dispatched the notification
    private func setListeners() {
        // Register for notifications to allow changing the status and the action block at run time form anywhere in the app
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TapConstantManager.TapBackButtonVisibilityNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TapConstantManager.TapBackButtonBlockNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StnNotificationExist(_:)), name: NSNotification.Name(rawValue: TapConstantManager.TapBackButtonVisibilityNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StnNotificationExist(_:)), name: NSNotification.Name(rawValue: TapConstantManager.TapBackButtonBlockNotification), object: nil)
    }
    
    
    /**
     Handles the logic needed to recieve the notifiations from other parts in the SDK to change the visibility and the action block of the back button
     - Parameter notification: The recieved notification object from the dispatcher object
     */
    @objc private func StnNotificationExist(_ notification:NSNotification)
    {
        // Let us decide if the notification is related to us, and if yes, let us decide its type and behave accordingly
        if notification.name.rawValue == TapConstantManager.TapBackButtonVisibilityNotification {
            // This is a back button visibilitr
            changeBackButtonVisibility(to: notification.userInfo?[TapConstantManager.TapBackButtonVisibilityNotification] as? Bool ?? false)
        }else if notification.name.rawValue == TapConstantManager.TapBackButtonBlockNotification {
            // This is a callback notification
            changeBackButtonCallback(with: notification.userInfo?[TapConstantManager.TapBackButtonBlockNotification] as? ()->())
            
        }
    }
    
    /// Adjusts the directions and RTL for needed views
    private func adjustDirections() {
        // Decide which direction should be used in the UIView based on the current selected locale
        let correctSemanticContent:UISemanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        // Adjust all the subviews marked to be localized based on direction
        toBeLocalizedViews.forEach{ $0.semanticContentAttribute = correctSemanticContent }
    }
    
    /// The back button is clicked handler
    @IBAction func backButtonClicked(_ sender: Any) {
        backActionHandler?()
    }
    
    /// Will show/hide the back button
    /// - Parameter to: If true, the back button will be visible and false otherwise.
    private func changeBackButtonVisibility(to:Bool) {
        // First check if we need to animate
        if to && backView.alpha != 1 {
            backView.fadeIn()
        }else if !to && backView.alpha != 0 {
            backView.fadeOut()
        }
    }
    
    /// Will show/hide the back button
    /// - Parameter with backActionHandler: The action handler to be called when the back button is clicked
    private func changeBackButtonCallback(with backActionHandler:(()->())?) {
        self.backActionHandler = backActionHandler
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
        // Powered by tap logo
        poweredByTapLogo.image = TapThemeManager.imageValue(for: "\(themePath).tapLogo")
        poweredByTapLogo.contentMode = TapLocalisationManager.shared.localisationLocale == "ar" ? .left : .right
        backgroundColor = .clear
        layoutIfNeeded()
        
        // The background bluring effect
        cardBlur.scale = 1
        cardBlur.blurRadius = 6
        cardBlur.colorTint = TapThemeManager.colorValue(for: "\(themePath).blurColor")
        cardBlur.colorTintAlpha = CGFloat(TapThemeManager.numberValue(for: "\(themePath).blurAlpha")?.floatValue ?? 0)
        
        // The back view and contents
        backView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backButton.background")
        backIconImageView.tap_theme_tintColor = .init(keyPath: "\(themePath).backButton.arrowColor")
        
        backLabel.tap_theme_setTitleColor(selector: .init(keyPath: "\(themePath).backButton.labelColor"), forState: .normal)
        backLabel.tap_theme_tintColor = .init(keyPath: "\(themePath).backButton.labelColor")
        backLabel.titleLabel?.tap_theme_font = .init(stringLiteral:"\(themePath).backButton.labelFont",shouldLocalise: true)
        backLabel.titleEdgeInsets = .init(top: TapLocalisationManager.shared.localisationLocale == "ar" ? 4 : 0, left: 0, bottom: 0, right: 0)
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
