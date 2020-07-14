//
//  TapOtpViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public protocol TapOtpViewModelDelegate: class {
    func updateMessage()
    func updateTimer(currentTime: String)
    func validateOtp(otpDigits: String)
    func otpExpired()
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
    
    var message: String {
        return self.state.message(mobileNo: phoneNo)
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
    
    // MARK: State Change
    func stateDidChange() {
        switch self.state {
        case .ready:
            self.delegate?.validateOtp(otpDigits: self.otpValue)
            
        case .invalid, .expired:
            self.delegate?.updateMessage()
            
        case .empty:
            self.timer.start()
            self.delegate?.updateMessage()
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
    
}

extension TapOtpViewModel: TapTimerDelegate {
    func onTimeFinish() {
        self.state = .expired
    }
    
    func onTimeUpdate(minutes: Int, seconds: Int) {
        self.delegate?.updateTimer(currentTime: "\(minutes):\(seconds)")
    }
    
    
}
