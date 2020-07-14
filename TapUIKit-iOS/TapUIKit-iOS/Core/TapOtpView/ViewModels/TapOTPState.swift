//
//  TapOTPState.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public enum TapOTPState {
    case empty
    case invalid
    case ready
    case expired
    
    func message(mobileNo: String = "") -> String {
        switch self {
        case .empty, .expired, .ready:
            return "OTP has been sent to " + mobileNo
        case .invalid:
            return "Invalid OTP number!"
        }
    }
}

