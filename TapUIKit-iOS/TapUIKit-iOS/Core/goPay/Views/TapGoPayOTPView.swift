//
//  TapGoPayOTPView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
/// External protocol to allow the TapGoPayOTPView to pass back data and events to the parent UIViewControlle
@objc public protocol TapGoPayOTPViewProtocol {
    /// Will be fired once the user asks to change the phone written in the previous step
    @objc func changePhoneClicked()
    /// Will be fired once the otp is expired
    @objc func otpStateExpired()
    /**
     An event will be fired once the user enter all the otp digits
     - Parameter otpValue: the OTP value entered by user
     */
    @objc func validateOTP(with otp:String)
    
}

/// Represents the view that shows the OTP + the hint + the change button
@objc public class TapGoPayOTPView: UIView {
    /// The super view that holds everything
    @IBOutlet var contentView: UIView!
    /// The upper hint view that shows the phone and the change button
    @IBOutlet weak var hintView: TapHintView!
    /// The OTP view correctly themable and customised
    @IBOutlet weak var otpView: TapOtpView!
    /// The view model needed to create the upper hint view
    internal var hintViewModel:TapHintViewModel = .init(with: .GoPayOtp)
    /// The view model needed to setup the OTP view
    internal var otpViewModel:TapOtpViewModel = .init()
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// External protocol to allow the TapGoPayOTPView to pass back data and events to the parent UIViewControlle
    @objc public var delegate:TapGoPayOTPViewProtocol?
    
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
        self.contentView = setupXIB()
        hintViewModel.delegate = self
        hintView.setup(with: hintViewModel)
        applyTheme()
    }
    
    /**
     Setup the view and show proper message
     - Parameter phone: The phone that was entered by the user in the previous step
     - Parameter expires: The duration in seconds after which, the OTP will expire
     */
    @objc public func setup(with phone:String,expires after:Int) {
        hintViewModel.appendTitle = phone
        otpViewModel.delegate = self
        otpViewModel.updateTimer(minutes: 0, seconds: after)
        otpView.setup(with: otpViewModel)
        otpViewModel.updateTimer(minutes: 0, seconds: after)
    }
}




// Mark:- Theme methods
extension TapGoPayOTPView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        tap_theme_backgroundColor = .init(keyPath: "goPay.passwordView.backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}


extension TapGoPayOTPView:TapOtpViewModelDelegate {
    public func otpStateReadyToValidate(otpValue: String) {
        delegate?.validateOTP(with: otpValue)
    }
    
    public func otpStateExpired() {
        delegate?.otpStateExpired()
    }
}


extension TapGoPayOTPView:TapHintViewModelDelegate {
    public func hintViewClicked(with viewModel: TapHintViewModel) {
        delegate?.changePhoneClicked()
    }
    
    
}

