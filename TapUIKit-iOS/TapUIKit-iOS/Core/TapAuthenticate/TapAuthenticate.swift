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
    /// An event will be fired once the authentication process success
    @objc func authenticationSuccess()
    
    /**
       An event will be fired once  the authentication process failed
    - Parameter error: return the error caused to authentication failure
    */
    @objc func authenticationFailed(with error: Error?)
}

/// Authentication types
@objc public enum BiometricType: Int {
    /// both touch id and face id are not available
    case none
    /// touch id type
    case touchID
    /// face id type
    case faceID
}

/// Tap authenticate handler to manage the authentication process
@objc public class TapAuthenticate: NSObject {
    
    private let context = LAContext()
    private var error: NSError?
    /// Reason of using face id and touch id authentication, it will be shown to the user while asking the user for authentication
    private var reason: String
    /// Returns the available biometric type in the current device, .none if not available
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
    
    /**
     Initialize tap authenticate instance
     - Parameter reason: the message will be shown to the user while asking for authentication
     */
    public init(reason: String) {
        self.reason = reason
    }
    
    /**
     Check if authentication is available in the current device
     - Returns: returns true authentication is enabled
     */
    internal func authenticationEnabled() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
        
    /// Start authentication process
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
            /// authentication is not available in the current device
            self.delegate?.authenticationFailed(with: error)
        }
    }
}
