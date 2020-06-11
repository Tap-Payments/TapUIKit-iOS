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
import class UIKit.UIView
import struct UIKit.CGFloat
import struct UIKit.CACornerMask
// MARK:- UIImageView extensions

internal typealias SimpleClosure = (() -> ())
private var actionKey : UInt8 = 1
internal extension UIImageView {
    // MARK:- Making the image view tappable extension
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

internal extension UIImage {
    // MARK:- Loading UIImage from a given class's bundle
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

internal extension UIView {
    // MARK:- Making corner radious for certain corners
    /**
    Assigns a radious value to certain corners
    - Parameter corners: The  corners we want to apply the radious to
    - Parameter radius: The radius value we want  to apply
    */
    func tapRoundCorners(corners:CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = CGFloat(radius)
        self.clipsToBounds = true
        self.layer.maskedCorners = corners
    }
    
    
    // MARK:- Loading a nib dynamically
    /**
     Load a XIB file into a UIView
     - Parameter bundle: The bundle to load the XIB from, default is the XIB containing the UIView
     - Parameter identefier: The name of the XIB, default is the name of the UIView
     - Parameter addAsSubView: Indicates whether the method should add the loaded XIB into the UIView, default is true
     */
    func setupXIB(from bundle:Bundle? = nil, with identefier: String? = nil, then addAsSubView:Bool = true) -> UIView {
        
        // Whether we use the passed bundle if any, or by default we use the bundle that contains the caller UIView
        let bundle = bundle ?? Bundle(for: Self.self)
        // Whether we use the passed identefier if any, or by default we use the default identefier for self
        let identefier = identefier ??  String(describing: type(of: self))
        
        // Load the XIB file
        guard let nibs = bundle.loadNibNamed(identefier, owner: self, options: nil),
            nibs.count > 0, let loadedView:UIView = nibs[0] as? UIView else { fatalError("Couldn't load Xib \(identefier)") }
        
        let newContainerView = loadedView
        
        //Set the bounds for the container view
        newContainerView.frame = bounds
        newContainerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        // Check if needed to add it as subview
        if addAsSubView {
            addSubview(newContainerView)
        }
        return newContainerView
    }
}

// MARK:- Encodable extensions

extension Encodable {
    // MARK:- Convert an Encodable to Dictionary
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

// MARK:- Decodable extensions
extension Decodable {
    // MARK:- Create from Dictionary or array
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}
