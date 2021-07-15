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
    /// A method to instruc the view to show / hide message label on the view
    func updateMessageVisibility(hide: Bool)
    /// A method to instruc the view to update status message
    func updateMessage()
    /**
     A method to instruc update the timer
     - Parameter currentTime: The remaining time until the OTP get expired
     */
    func updateTimer(currentTime: String)
    /// A method to instruc the view to update view on otp state becomes expired
    func otpExpired()
    /// A method to instruc the view to enable editing otp view on state becomes empty
    func enableOtpEditing()
    /// A method to instruc the view to reset all the UI
    func resetUI()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapOtpViewModelDelegate {
    /**
     An event will be fired once the user enter all the otp digits
     - Parameter otpValue: the OTP value entered by user
     */
    @objc func otpStateReadyToValidate(otpValue: String)
    
    /**
     An event will be fired everytime the statuse of the OTP  state changes
     - Parameter to: the new status of the otp view
     */
    @objc func otpState(changed to:TapOTPStateEnum)
    
    /**
     An event will be fired once the timer stopped and the state became expired
     */
    @objc func otpStateExpired()
}


/// The view model that controls the tap otp view
@objc public class TapOtpViewModel: NSObject {
    
    /// Timer to be used in counting down to update the state to expired
    private var timer: TapTimer?
    
    /// Showing the current state of the otp, default is .empty
    @objc public var state: TapOTPStateEnum = .empty {
        didSet {
            self.stateDidChange()
        }
    }
    
    /// Phone number to be used in the message depending on the state
    internal var phoneNo: String
    /// Showing the message label if set to true, default is false
    private var showMessage: Bool
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate:TapOtpViewDelegate? {
        didSet {
            self.state = .empty
        }
    }
    
    /// The delegate used to fire events to the parent view
    @objc public var delegate:TapOtpViewModelDelegate?
    
    /// The OTP digits entered by the user
    var otpValue = "" {
        didSet {
            self.updateState()
        }
    }
    
    /// The OTP digits entered by the user
    var currentOtpValue: String {
        get{
            return otpValue
        }
    }
    
    /**
     Creates a view model with the phone number and showing message flag
     - Parameter phoneNo: The phone number
     - Parameter showMessage: should show message lebel, set to true to show the message
     */
    public init(phoneNo: String, showMessage: Bool) {
        self.phoneNo = phoneNo
        self.showMessage = showMessage
    }
    
    // MARK: UpdateTimer
    /**
     Initialize the timer and set the delegate with the required minutes and seconds until otp expire
     - Parameter minutes: number of minutes until the otp expire
     - Parameter seconds: number of seconds until the otp expire
     */
    @objc public func updateTimer(minutes: Int, seconds: Int) {
        if timer == nil {
            self.timer = TapTimer(minutes: minutes, seconds: seconds)
        }
        if self.timer?.delegate == nil {
            self.timer?.delegate = self
        }
    }
    
    // MARK: Message
    /**
     Returns NSAttributedString with the message using mainColor and secondColor
     - Parameter mainColor: default text color to be used in the formatted text
     - Parameter secondaryColor: second text color to be set for the mobile number text
     */
    func messageAttributed(mainColor: UIColor, secondaryColor: UIColor) -> NSAttributedString {
        return self.state.message(mobileNo: phoneNo, mainColor: mainColor, secondaryColor: secondaryColor)
    }
    
    // MARK: State Change
    /**
     This method apply the required functionality and delegates on state change
     */
    func stateDidChange() {
        // First inform the view that we need to change the message shown based on the setup
        self.viewDelegate?.updateMessageVisibility(hide: !showMessage)
        // Based on the state changd we will decide what to do
        switch self.state {
        case .ready:
            self.delegate?.otpStateReadyToValidate(otpValue: otpValue)
            
        case .invalid:
            self.updateMessageViewDelegate()
            
        case .expired:
            self.viewDelegate?.otpExpired()
            self.delegate?.otpStateExpired()
            
        case .empty:
            if let timer = timer {
                timer.start()
            }
            self.updateMessageViewDelegate()
            self.viewDelegate?.enableOtpEditing()
        }
        
        delegate?.otpState(changed: state)
    }
    /**
     This function update the state on otp digits change
     */
    func updateState() {
        if self.otpValue.count == 6 {
            // all otp digits got filled
            self.state = .ready
        } else {
            if self.state != .empty {
                // otp digits not filled completely
                // set otp state to initial (default) state
                self.state = .empty
            }
        }
    }
    
    /**
     Create OTP view and prepare the view to be ready
     */
    @objc public func createOtpView() -> TapOtpView {
        let tapOtpView:TapOtpView = .init()
        tapOtpView.translatesAutoresizingMaskIntoConstraints = false
        tapOtpView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapOtpView.setup(with: self)
        return tapOtpView
    }
    
    /**
     This method calls the viewDelegate to update the message view
     */
    func updateMessageViewDelegate() {
        if self.showMessage {
            self.viewDelegate?.updateMessage()
        }
    }
    
    // MARK: Reset
    /**
     Reset the state to the initialize state
     */
    @objc public func resetStateReady() {
        self.state = .empty
    }
    
    /**
     Invalidate OTP timer and reset all properties and delegates
     */
    @objc public func close() {
        self.viewDelegate?.resetUI()
        self.timer?.delegate = nil
        self.timer?.reset()
        self.timer = nil
        self.delegate = nil
        self.viewDelegate = nil
    }
}

extension TapOtpViewModel: TapTimerDelegate {
    /**
     This function is being called on the remaining time reach to zero seconds
     */
    func onTimeFinish() {
        self.state = .expired
    }
    
    /**
     This function is being called on the timer update the remaining time
     */
    func onTimeUpdate(minutes: Int, seconds: Int) {
        self.viewDelegate?.updateTimer(currentTime: String(format: "%02d:%02d", minutes, seconds))
    }
}
