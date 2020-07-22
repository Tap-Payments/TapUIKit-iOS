//
//  TapAuthenticate.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/22/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import LocalAuthentication

@objc public class TapAuthenticate: NSObject {
    let context = LAContext()
    var error: NSError?
    var reason: String
    
    init(reason: String) {
        self.reason = reason
    }
    
    func authenticationEnabled() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate() {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] success, authenticationError in
//            DispatchQueue
        }
    }
    
    
}
