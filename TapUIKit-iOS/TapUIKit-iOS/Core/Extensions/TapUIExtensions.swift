//
//  TapUIImageViewExtensions.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 28/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// This will be a class that holds the extensions developed to the UIImageview needed to simplify the development of the different ui kits
import class UIKit.UIImage
import class UIKit.UIImageView
import class UIKit.UITapGestureRecognizer
import TapThemeManager2020

// MARK:- UIImageView extensions
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

// MARK:- UIImage extensions
// MARK:- Loading UIImage from a given class's bundle
internal extension UIImage {
    
    /**
     Load an Image asset from a dynamic bundle based on the caller class type
     - Parameter name: The name of theimage you want to load
     - Parameter classType: type(of:class) where class is the original class where you want to load the image from its bundle
     */
    static func loadLocally(with name:String,from classType:AnyClass) -> UIImage? {
        let bundle:Bundle = Bundle(for:classType)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}



// MARK:- UIView extensions
// MARK:- Making corner radious for certain corners
extension UIView {
    /**
    Assigns a radious value to certain corners
    - Parameter corners: The  corners we want to apply the radious to
    - Parameter radius: The radius value we want  to apply
    */
    func tapRoundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
