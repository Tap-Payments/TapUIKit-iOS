//
//  TapAuthenticate.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/22/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import LocalAuthentication

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapAuthenticateDelegate {
    /**
       An event will be fired once the main switch toggled
    - Parameter enabled: return current switch state
    */
    @objc func authenticationSuccess()
    
    /**
       An event will be fired once the main switch toggled
    - Parameter enabled: return current switch state
    */
    @objc func authenticationFailed(with error: Error?)
}


@objc public class TapAuthenticate: NSObject {
    
    public enum BiometricType: Int {
        case none
        case touchID
        case faceID
    }
    
    private let context = LAContext()
    private var error: NSError?
    private var reason: String
    
    public var type: BiometricType {
        if self.authenticationEnabled() {
            if context.biometryType == .touchID {
                return .touchID
            }
            if context.biometryType == .faceID {
                return .faceID
            }
        }
        return .none
    }
    
    /// The delegate used to fire events on authentication
    @objc public var delegate:TapAuthenticateDelegate?
    
    public init(reason: String) {
        self.reason = reason
    }
    
    internal func authenticationEnabled() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /**
        Authenticate
     */
    public func authenticate() {
        if self.authenticationEnabled() {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.delegate?.authenticationSuccess()
                    } else {
                        self.delegate?.authenticationFailed(with: authenticationError)
                    }
                }
            }
        } else {
            self.delegate?.authenticationFailed(with: error)
        }
    }
}
