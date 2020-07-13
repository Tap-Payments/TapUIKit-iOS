//
//  TapOtpViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

public protocol TapOtpViewModelDelegate: class {
    func reloadUI()
}

@objc public class TapOtpViewModel: NSObject {
    var state: TapOTPState = .Empty {
        didSet {
            self.delegate?.reloadUI()
        }
    }
    var phoneNo: String = ""
    
    weak var delegate: TapOtpViewModelDelegate? {
        didSet {
            self.delegate?.reloadUI()
        }
    }
    
    var message: String {
        return self.state.message(mobileNo: phoneNo)
    }
}
