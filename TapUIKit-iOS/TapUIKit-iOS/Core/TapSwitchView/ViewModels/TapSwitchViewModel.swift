//
//  TapSwitchViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// A protocol to be used to fire functions and events in the associated view
internal protocol TapSwitchViewDelegate {
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapSwitchViewModelDelegate {
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

@objc public class TapSwitchViewModel: NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate: TapSwitchViewDelegate?// TapOtpViewDelegate?
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapSwitchViewModelDelegate?
    
    
    /**
        This
    */
    @objc public func createSwitchView() -> TapSwitchView {
        let tapSwitchView:TapSwitchView = .init()
        tapSwitchView.translatesAutoresizingMaskIntoConstraints = false
        tapSwitchView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapSwitchView.setup(with: self)
        return tapSwitchView
    }
}
