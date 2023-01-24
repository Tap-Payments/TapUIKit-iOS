//
//  TapGoPayOTPView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS
import TapAdditionsKitV2

/// External protocol to allow the TapGoPayOTPView to pass back data and events to the parent UIViewControlle
@objc public protocol TapGoPayOTPViewProtocol {
    /// Will be fired once the user asks to change the phone written in the previous step
    @objc func changePhoneClicked()
    /// Will be fired once the otp is expired
    /// - Parameter with otpType : Indicate to the delegate which OTP view is this, Saved card or goPay sign in
    @objc func otpStateExpired(with otpType:TapHintViewStatusEnum)
    /**
     An event will be fired once the user enter all the otp digits
     - Parameter otpValue: the OTP value entered by user
     */
    @objc func validateAuthenticationOTP(with otp:String)
    
    /**
     An event will be fired once the user enter all the otp digits
     - Parameter otpValue: the OTP value entered by user
     - Parameter phone: The phone number used to send the OTP to
     */
    @objc func validateGoPayOTP(with otp:String,for phone:String)
    
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
    internal var hintViewModel:TapHintViewModel = .init(with: .SavedCardOTP)
    /// The view model needed to setup the OTP view
    internal var otpViewModel:TapOtpViewModel = .init(phoneNo: "", showMessage: false)
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
     - Parameter hintViewStatus: Decides The theme, title and action button shown on the top of the OTP view based on the type
     */
    @objc public func setup(with phone:String,expires after:Int,hintViewStatus:TapHintViewStatusEnum = .GoPayOtp) {
        // Adjust the Hint view
        setupHintView(with: hintViewStatus, and: TapLocalisationManager.shared.localisationLocale == "ar" ? phone.replacingOccurrences(of: " ", with: "") : phone)
        // Adjust the otpview itself
        otpViewModel.delegate = self
        otpViewModel.updateTimer(minutes: 0, seconds: after)
        otpView.setup(with: otpViewModel)
        otpViewModel.updateTimer(minutes: 0, seconds: after)
    }
    
    /**
     The logic to setup the hint view shown above the OTP view itself
     - Parameter appendTitle: The phone that was entered by the user in the previous step
     - Parameter hintViewStatus: Decides The theme, title and action button shown on the top of the OTP view based on the type
     - Parameter appendTitle: An optional string to append to the hint view label if required
     */
    internal func setupHintView(with hintViewStatus:TapHintViewStatusEnum = .GoPayOtp,and appendTitle:String = "") {
        hintViewModel = .init(with: hintViewStatus)
        hintViewModel.delegate = self
        hintView.setup(with: hintViewModel)
        hintViewModel.appendTitle = appendTitle
    }
    
    /// A computed variable that indicate what should the button looks like and what action to perform on the action button based on the OTP status
    internal func otpAction() {
        
        // init default data
        var actionButtonBlock:()->() = {}
        var buttonStatus:TapActionButtonStatusEnum = .InvalidConfirm
        // Based on the otp view model state, let us decide what to do
        switch otpViewModel.state {
        case .expired,.ready:
            // Those already handled by the below methods each are being called as a delegate method
            break
        default:
            buttonStatus = .InvalidConfirm
            actionButtonBlock = { }
            
            // INform the action button with the new status and the new action block
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:buttonStatus] )
        }
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
    
    public func otpState(changed to: TapOTPStateEnum) {
        otpAction()
    }
    
    public func otpStateReadyToValidate(otpValue: String) {
        // Update the button state to valid CONFIRM state
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.ValidConfirm])
        // Based on the view status we decide which delegate method we should call
        var actionButtonBlock:()->() = {}
        
        if hintViewModel.tapHintViewStatus == .GoPayOtp {
            // If gopay otp login, then we need to indicate the view model to verify the gopay otp
            actionButtonBlock = { self.delegate?.validateGoPayOTP(with: otpValue,for: self.otpViewModel.phoneNo) }
        }else if hintViewModel.tapHintViewStatus == .SavedCardOTP {
            // In the case of the saved card OTP verification, we need to indicate the delegate that he needs to verify this OTP as per the saved card
            actionButtonBlock = { self.delegate?.validateAuthenticationOTP(with: otpValue) }
        }
        
        // Inform the button to have the new action block
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
    }
    
    
    public func otpStateExpired() {
        
        delegate?.otpStateExpired(with: hintViewModel.tapHintViewStatus)
        // Close the OTP view
        self.otpViewModel.close()
        guard hintViewModel.tapHintViewStatus != .SavedCardOTP else { return }
        // Update the button state to valid resend state
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.ResendOTP])
        // Define the action block for the action button
        let actionButtonBlock = { self.delegate?.otpStateExpired(with: self.hintViewModel.tapHintViewStatus) }
        // Inform the button to have the new action block
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
    }
}


extension TapGoPayOTPView:TapHintViewModelDelegate {
    public func hintViewClicked(with viewModel: TapHintViewModel) {
        delegate?.changePhoneClicked()
    }
    
    
}

