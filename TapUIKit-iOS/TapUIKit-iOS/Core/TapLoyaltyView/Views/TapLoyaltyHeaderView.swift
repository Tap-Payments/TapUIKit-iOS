//
//  TapLoyaltyHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import Foundation
import Nuke
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import TapThemeManager2020

/// A protocol to listen to UI events fired from the loyalty header view
protocol TapLoyaltyHeaderDelegate {
    
    /// Will be fired when the terms and conditions button is clicked
    func termsAndConditionsClicked()
    
    /**
     Will be fired when the enable/disable switch is changed
     - Parameter enable: If true, it means enable the program otherwise disable it
     */
    func enableLoyaltySwitch(enable:Bool)
    
}

/// A view represents the header view of the loyalty widget
internal class TapLoyaltyHeaderView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// Displays the logo icon for the loyalty program
    @IBOutlet weak var loyaltyLogo: UIImageView!
    /// Displays the title header including the name of the loyalty program
    @IBOutlet weak var loyaltyHeaderTitleLabel: UILabel!
    /// Displays the sub title header including the name of the loyalty program
    @IBOutlet weak var loyaltyHeaderSubtitleLabel: UILabel!
    /// A switch to enable/disable using the loyalty program
    @IBOutlet weak var loyaltyHeaderEnableSwitch: UISwitch!
    /// A button to show the terms and conditions of a the loyalty program
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    /// A protocol to listen to UI events fired from the loyalty header view
    internal var delegate:TapLoyaltyHeaderDelegate?
    /// list of views that needs to be forceable RTL support if needed
    @IBOutlet var toBeLocalisedViews: [UIView]!
    
    /// The path to look for theme entry in
    private let themePath = "loyaltyView.headerView"
    
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
        
        toBeLocalisedViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
        applyTheme()
    }
    
    
    // MARK: Private
    /**
     Will stup the content of the view with the given data
     - Parameter with logo: The logo of the loyalty program
     - Parameter headerText: The text to display in the title label
     - Parameter subtitleText: The text to display in the sub title label
     - Parameter isEnabled: Indicates whether or not to enable the switch usage of the loyalty
     - Parameter termsAndConditionsEnabled: Indicates whether or not there is T&C to display for this loyalty program
     */
    internal func setup(with logo:URL?, headerText:String?, subtitleText:String?, isEnabled:Bool, termsAndConditionsEnabled:Bool) {
        
        // Load the logo url
        if let nonNullLogoUrl = logo {
            Nuke.loadImage(with: nonNullLogoUrl, into: loyaltyLogo, completion:  { [weak self] _ in
                self?.loyaltyLogo.fadeIn()
            })
        }
        
        // Set the textual contents
        loyaltyHeaderTitleLabel.text = headerText
        loyaltyHeaderSubtitleLabel.text = subtitleText
        
        // Set the enablement switch
        loyaltyHeaderEnableSwitch.isOn = isEnabled
        
        // Set the T&C button visibility
        termsAndConditionsButton.isHidden = !termsAndConditionsEnabled
    }
    
    
    // MARK: UI Fired Functions
    /// Indicates the user clicked on terms and conditions clicked
    @IBAction func termsButtonClicked(_ sender: Any) {
        // Infom the delegate
        delegate?.termsAndConditionsClicked()
    }
    /// Indicates the user changes the state of the enablement switch
    @IBAction func enablementSwitchChanged(_ sender: Any) {
        // Infom the delegate
        delegate?.enableLoyaltySwitch(enable: loyaltyHeaderEnableSwitch.isOn)
    }
    
}



// Mark:- Theme methods
extension TapLoyaltyHeaderView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        loyaltyHeaderTitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleFont")
        loyaltyHeaderTitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).titleTextColor")
        
        loyaltyHeaderSubtitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).subTitleFont")
        loyaltyHeaderSubtitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).subTitleTextColor")
        
        loyaltyHeaderEnableSwitch.tap_theme_onTintColor = .init(keyPath: "\(themePath).switchOnTintColor")
        
        
        
        let termsAndConditionsAttributedTitle = NSMutableAttributedString(string: "\(TapLocalisationManager.shared.localisedValue(for: "TapLoyaltySection.headerView.tc", with: TapCommonConstants.pathForDefaultLocalisation()))",
                                                                          attributes: [
                                                                            .foregroundColor : TapThemeManager.colorValue(for: "\(themePath).subTitleTextColor") ?? .gray,
                                                                            .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                                            .font : TapThemeManager.fontValue(for: "\(themePath).subTitleFont") ?? .systemFont(ofSize: 11)])
        
        termsAndConditionsButton.setAttributedTitle(termsAndConditionsAttributedTitle, for: .normal)
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
