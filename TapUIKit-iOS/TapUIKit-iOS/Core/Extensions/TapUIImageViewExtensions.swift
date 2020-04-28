//
//  TapUIImageViewExtensions.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 28/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// This will be a class that holds the extensions developed to the UIImageview needed to simplify the development of the different ui kits
import Foundation
import UIKit



// MARK:- Making the image view tappable extension
internal typealias SimpleClosure = (() -> ())
private var actionKey : UInt8 = 1
internal extension UIImageView {
    
    // The callback function that will be set when the caller wants to make it as clickable
    var callback: SimpleClosure {
        get {
            return objc_getAssociatedObject(self, &actionKey) as! SimpleClosure
        }
        set {
            objc_setAssociatedObject(self, &actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            addTapGesture()
        }
    }
    
    /// The tap gesture recognizer that listens to the tap
    private var gesture: UITapGestureRecognizer {
        get {
            return UITapGestureRecognizer(target: self, action: #selector(tapped))
        }
    }
    
    /// Method for adding a new tap gesture recognizer and removes the old ones first
    fileprivate func addTapGesture() {
        // Disable all the old gestures if any
        if let attachedGestures = self.gestureRecognizers {
            for l in 0 ..< attachedGestures.count {
               self.gestureRecognizers![l].isEnabled = false
            }
        }
        
        self.gesture.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gesture)
    }

    @objc private func tapped() {
        callback()
    }
}
