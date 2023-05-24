//
//  TapCurrencyWidgetView.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 24/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit

class TapCurrencyWidgetView: UIView {


    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The confirm button to change the currency to be accepted by this provider
    @IBOutlet weak var confirmButton: UIButton!
    /// The amount label which displays amount after conversion to be used with this provider
    @IBOutlet weak var amountLabel: UILabel!
    /// The currency View image view which displays currency to be used with this provider
    @IBOutlet weak var currencyImageView: UIImageView!
    /// The message label  which displays the CurrencyWidget message
    @IBOutlet weak var messageLabel: UILabel!
    /// The provider image view which displays the provider logo
    @IBOutlet weak var providerImageView: UIImageView!

    /// The path to look for theme entry in
    private let themePath = "CurrencyWidget"
    
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
        applyTheme()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// When user click on confirm button
    @IBAction func confirmClicked(_ sender: Any) {
    }
    
}

// Mark:- Theme methods
extension TapCurrencyWidgetView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let amountLabelThemePath = "\(themePath).amountLabel"
        amountLabel.tap_theme_font = .init(stringLiteral: "\(amountLabelThemePath).font")
        amountLabel.tap_theme_textColor = .init(keyPath: "\(amountLabelThemePath).color")
        
        let messageLabelThemePath = "\(themePath).messageLabel"
        messageLabel.tap_theme_font = .init(stringLiteral: "\(messageLabelThemePath).font")
        messageLabel.tap_theme_textColor = .init(keyPath: "\(messageLabelThemePath).color")
        
        let backgroundThemePath = "\(themePath).background"
        containerView.tap_theme_backgroundColor = .init(keyPath: "\(backgroundThemePath).color")
        containerView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(backgroundThemePath).cornerRadius")
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = false
        containerView.layer.shadowOpacity = 1
        containerView.layer.tap_theme_shadowRadius = .init(keyPath: "\(backgroundThemePath).shadow.blurRadius")
        containerView.layer.tap_theme_shadowColor = .init(keyPath: "\(backgroundThemePath).shadow.color")
        
        let confirmButtonThemePath = "\(themePath).confirmButton"
        
        confirmButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(confirmButtonThemePath).titleFontColor"), forState: .normal)
        confirmButton.tap_theme_tintColor = .init(keyPath: "\(confirmButtonThemePath).titleFontColor")
        confirmButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(confirmButtonThemePath).titleFont")
        confirmButton.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(confirmButtonThemePath).cornerRadius")
        confirmButton.tap_theme_backgroundColor = .init(keyPath: "\(confirmButtonThemePath).backgroundColor")
        

        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
