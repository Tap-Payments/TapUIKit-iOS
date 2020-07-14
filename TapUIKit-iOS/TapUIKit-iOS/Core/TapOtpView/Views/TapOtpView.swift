//
//  TapOtpView.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

@objc public class TapOtpView: UIView {
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet weak var otpController: TapOtpController!
    
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel = TapOtpViewModel(minutes: 0, seconds: 30)

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
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
        
        // Whenever the view model is assigned, we delcare ourself as the  delegate to start getting load UI
        viewModel.delegate = self
        otpController.delegate = self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
}

extension TapOtpView: TapOtpViewModelDelegate {
    public func validateOtp(otpDigits: String) {
        // should call validate otp api
        
    }
    
    public func updateTimer(currentTime: String) {
        self.timerLabel.text = currentTime
    }
    
    public func updateMessage() {
        self.messageLabel.text = viewModel.message
    }
    
    public func otpExpired() {
        // enable resend button
    }
}

extension TapOtpView: TapOtpControllerDelegate {
    func digitsDidChange(newDigits: String) {
        viewModel.otpValue = newDigits
    }
}

// Mark:- Theme methods
extension TapOtpView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
//        amountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).originalAmountLabelFont",shouldLocalise:false)
//        amountLabel.tap_theme_textColor = .init(keyPath: "\(themePath).originalAmountLabelColor")
//
//        convertedAmountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).convertedAmountLabelFont",shouldLocalise:false)
//        convertedAmountLabel.tap_theme_textColor = .init(keyPath: "\(themePath).convertedAmountLabelColor")
//
//        itemsNumberLabel.tap_theme_font = .init(stringLiteral: "\(themePath).itemsLabelFont")
//        itemsNumberLabel.tap_theme_textColor = .init(keyPath: "\(themePath).itemsLabelColor")
//
//        itemsHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).itemsNumberButtonBackgroundColor")
//        itemsHolderView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).itemsNumberButtonCorner")
//        itemsHolderView.layer.tap_theme_borderWidth = .init(keyPath: "\(themePath).itemsNumberButtonBorder.width")
//        itemsHolderView.layer.tap_theme_borderColor = .init(keyPath: "\(themePath).itemsNumberButtonBorder.color")
//
//        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
