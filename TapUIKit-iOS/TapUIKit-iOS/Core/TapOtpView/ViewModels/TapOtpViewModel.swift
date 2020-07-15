//
//  TapOtpViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import  UIKit

public protocol TapOtpViewModelDelegate: class {
    func updateMessage()
    func updateTimer(currentTime: String)
    func validateOtp(otpDigits: String)
    func otpExpired()
    func enableOtpEditing()
}

@objc public class TapOtpViewModel: NSObject {
    
    
    var timer: TapTimer
    var state: TapOTPState = .empty {
        didSet {
            self.stateDidChange()
        }
    }
    var phoneNo: String = ""
    
    weak var delegate: TapOtpViewModelDelegate? {
        didSet {
            self.state = .empty
            self.timer.delegate = self
        }
    }
    
    var otpValue = "" {
        didSet {
            self.updateState()
        }
    }
    
    // MARK: Init
    init(minutes: Int, seconds: Int) {
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
            self.delegate?.validateOtp(otpDigits: self.otpValue)
            
        case .invalid:
            self.delegate?.updateMessage()
            
        case .expired:
            self.delegate?.otpExpired()
            
        case .empty:
            self.timer.start()
            self.delegate?.updateMessage()
            self.delegate?.enableOtpEditing()
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
        self.delegate?.updateTimer(currentTime: String(format: "%02d:%02d", minutes, seconds))//(currentTime: "\(minutes):\(seconds)")
        
    }
    
    
}
