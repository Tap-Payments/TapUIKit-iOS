//
//  TapOTPState.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public enum TapOTPState {
    case Empty
    case Invalid
    case Ready
    case expired
    
    func message(mobileNo: String = "") -> String {
        switch self {
        case .Empty, .expired, .Ready:
            return "OTP has been sent to " + mobileNo
        case .Invalid:
            return "Invalid OTP number!"
        }
    }
}

