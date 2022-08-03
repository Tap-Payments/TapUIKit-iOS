//
//  TapOtpView.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// The view  that renders a tap otp view
@objc public class TapOtpView: UIView {
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The message label that holds the description of the current OTP state
    @IBOutlet private weak var messageLabel: UILabel!
    /// The timer label that holds the remaining time until the OTP get expired
    @IBOutlet private weak var timerLabel: UILabel!
    /// This controller contains the OTP view
    @IBOutlet weak var otpController: TapOtpController!
    
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel:TapOtpViewModel = .init(phoneNo: "", showMessage: false)
    
    /// This contains the path of OTP view theme in the theme manager
    private let themePath = "TapOtpView"
    
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
        timerLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        messageLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    /// Updates the container view frame to the parent view bounds
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     */
    @objc public func setup(with viewModel:TapOtpViewModel) {
        self.viewModel = viewModel
        self.viewModel.viewDelegate = self
        self.otpController.delegate = self
    }
}

extension TapOtpView: TapOtpViewDelegate {
    func updateMessageVisibility(hide: Bool) {
        self.messageLabel.isHidden = hide
    }
    
    public func updateTimer(currentTime: String) {
        self.timerLabel.text = currentTime
    }
    
    public func updateMessage() {
        let status: TapOTPStateEnum = viewModel.state
        
        self.messageLabel.attributedText = viewModel.messageAttributed(mainColor: TapThemeManager.colorValue(for: "\(status.themePath()).Message.title") ?? .white, secondaryColor: TapThemeManager.colorValue(for: "\(status.themePath()).Message.subtitle") ?? .white)
    }
    
    public func otpExpired() {
        // enable resend button
        self.updateMessage()
        self.otpController.resetAll()
        self.otpController.enabled = false
    }
    
    public func enableOtpEditing() {
        self.otpController.enabled = true
    }
    
    public func resetUI() {
        self.otpController.resetAll()
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
        
        let status: TapOTPStateEnum = viewModel.state
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        timerLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).Timer.textColor")
        timerLabel.tap_theme_font = .init(stringLiteral: "\(themePath).Timer.textFont",shouldLocalise:false)
        
        self.messageLabel.tap_theme_font = .init(stringLiteral: "\(status.themePath()).Message.textFont")
        
        self.otpController.bottomLineColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.bottomLineColor") ?? .white
        self.otpController.bottomLineActiveColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.activeBottomColor") ?? .blue
        
        self.otpController.textColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.textColor") ?? .black
        self.otpController.font = TapThemeManager.fontValue(for: "\(themePath).OtpController.textFont") ?? .systemFont(ofSize: 12)
    }
    
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
