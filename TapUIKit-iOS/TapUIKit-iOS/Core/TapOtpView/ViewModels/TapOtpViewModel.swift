//
//  TapOtpViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import  UIKit

/// A protocol to be used to fire functions and events in the associated view
internal protocol TapOtpViewDelegate {
    /// A method to instruc the view to update status message
    func updateMessage()
    
    /// A method to instruc update the timer
    /// - Parameter currentTime: The remaining time until the OTP get expired
    func updateTimer(currentTime: String)
    
    /// A method to instruc the view to update view on otp state becomes expired
    func otpExpired()
    
    /// A method to instruc the view to enable editing otp view on state becomes empty
    func enableOtpEditing()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapOtpViewModelDelegate {
    /**
        An event will be fired once the user enter all the otp digits
     - Parameter otpValue: the OTP value entered by user
     */
    @objc func otpStateReadyToValidate(otpValue: String)
    
    /**
     An event will be fired once the timer stopped and the state became expired
     */
    @objc func otpStateExpired()
}


@objc public class TapOtpViewModel: NSObject {
    
    private var timer: TapTimer?
    @objc public var state: TapOTPState = .empty {
        didSet {
            self.stateDidChange()
        }
    }
    
    var phoneNo: String = ""
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate:TapOtpViewDelegate? {
        didSet {
            self.state = .empty
        }
    }
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapOtpViewModelDelegate?

    var otpValue = "" {
        didSet {
            self.updateState()
        }
    }

    // MARK: UpdateTimer
    @objc public func updateTimer(minutes: Int, seconds: Int) {
        if self.timer?.delegate == nil {
            self.timer?.delegate = self
        }
        self.timer = TapTimer(minutes: minutes, seconds: seconds)
    }
    
    // MARK: Message
    func messageAttributed(mainColor: UIColor, secondaryColor: UIColor) -> NSAttributedString {
        return self.state.message(mobileNo: phoneNo, mainColor: mainColor, secondaryColor: secondaryColor)
    }
    
    // MARK: State Change
    func stateDidChange() {
        switch self.state {
        case .ready:
            self.delegate?.otpStateReadyToValidate(otpValue: self.otpValue)
            
        case .invalid:
            self.viewDelegate?.updateMessage()
            
        case .expired:
            self.viewDelegate?.otpExpired()
            self.delegate?.otpStateExpired()
            
        case .empty:
            self.timer?.start()
            self.viewDelegate?.updateMessage()
            self.viewDelegate?.enableOtpEditing()
        }
    }
    
    func updateState() {
        if self.otpValue.count == 6 {
            self.state = .ready
        } else {
            if self.state != .empty {
                self.state = .empty
            }
        }
    }
    
    @objc public func createOtpView() -> TapOtpView {
        let tapOtpView:TapOtpView = .init()
        tapOtpView.translatesAutoresizingMaskIntoConstraints = false
        tapOtpView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapOtpView.setup(with: self)
        return tapOtpView
    }
    
    // MARK: Resend
    @objc public func resetStateReady() {
        self.state = .empty
    }
}

extension TapOtpViewModel: TapTimerDelegate {
    func onTimeFinish() {
        self.state = .expired
    }
    
    func onTimeUpdate(minutes: Int, seconds: Int) {
        self.viewDelegate?.updateTimer(currentTime: String(format: "%02d:%02d", minutes, seconds))
    }
}
