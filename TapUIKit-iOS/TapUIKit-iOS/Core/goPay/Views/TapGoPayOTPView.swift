//
//  TapGoPayOTPView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

@objc public protocol TapGoPayOTPViewProtocol {
    
    @objc func changePhoneClicked()
    @objc func otpStateExpired()
    @objc func validateOTP(with otp:String)
    
}

@objc public class TapGoPayOTPView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var hintView: TapHintView!
    @IBOutlet weak var otpView: TapOtpView!
    internal var hintViewModel:TapHintViewModel = .init(with: .GoPayOtp)
    internal var otpViewModel:TapOtpViewModel = .init(phoneNo: "", showMessage: false)
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
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

