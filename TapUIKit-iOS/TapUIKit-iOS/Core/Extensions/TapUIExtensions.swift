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

internal extension NSObject {
    /**
    Method used to decide which theme will we use from a given dict, given json or the default one
    - Parameter themeDictionary: Defines the theme needed to be applied as a dictionary if any. Default is nil
    - Parameter jsonTheme: Defines the theme needed to be applied as a json file file name if any. Default is nil
    */
    func themeSelector(themeDictionary:NSDictionary? = nil,jsonTheme:String? = nil) -> NSDictionary? {
        var themingDictionary:NSDictionary?
        if let nonNullCustomDictionaryTheme = themeDictionary {
            // The user provided a custom dictionary theme
            themingDictionary = nonNullCustomDictionaryTheme
        }else if let nonNullCustomJsonTheme = jsonTheme {
            // The user provided a custom json theme file
            themingDictionary = TapThemeManager.loadDictFrom(jsonName:nonNullCustomJsonTheme)
        }
        return themingDictionary
    }
}

internal extension UIView {
    
    func loadTheme(from bundle:Bundle,lightModeName:String,darkModeName:String? = nil) -> NSDictionary? {
        var themeFile:String = lightModeName
        // Check if the caller passed a dark mode support then we check if need to apply it
        if let nonNullDarkModeFile:String = darkModeName {
            themeFile = (self.traitCollection.userInterfaceStyle == .dark) ? nonNullDarkModeFile : lightModeName
        }
        // Check if the file exists // Based on the current display mode, we decide which default theme file we will use
        
        // Defensive code to make sure all is loaded correctly
        guard let jsonPath = bundle.path(forResource: themeFile, ofType: "json") else {
            print("TapThemeManager WARNING: Can't find json 'DefaultTheme'")
            return nil
        }
        // Check if the file is correctly parsable
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
            let jsonDict = json as? NSDictionary else {
                print("TapThemeManager WARNING: Can't read json 'DefaultTheme' at: \(jsonPath)")
                return nil
        }
        return jsonDict
    }
}
