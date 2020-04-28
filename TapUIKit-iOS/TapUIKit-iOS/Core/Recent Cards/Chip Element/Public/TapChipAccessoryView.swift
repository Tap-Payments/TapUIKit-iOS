//
//  TapChipAccessoryView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 28/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import UIKit
/// A class that represents the right accessory, left accessory views to be used in TapChip UI element
@objc public class TapChipAccessoryView:UIImageView {
    
    /// The click handler if the caller app wants to listen when the user clicks on this accessory
    internal var clickHandler:((TapChip) -> ())? = nil {
        didSet{
            assignClickHandler()
        }
    }
    
    internal weak var parentChip:TapChip?
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
    }
    
    internal override init(image: UIImage?) {
        super.init(image:image)
        self.image = image
        clickHandler = nil
        
    }
    
    /**
     Defines the Accessory view to be used inside TapChap ui element
     - Parameter image : The image you want to show inside the chip ui element
     - Parameter clickHandler : The handler to be called once the accessory is clicked, default is nil
     */
    @objc convenience public init(image: UIImage?,clickHandler:((TapChip) -> ())? = nil) {
        self.init(image:image)
        self.image = image
        self.contentMode = .scaleAspectFit
        self.clickHandler = clickHandler
        assignClickHandler()
    }
    
    /// This method will be responsible to add a click handler if defined for this accessory view
    internal func assignClickHandler() {
        // Check if the user defined a click handler and its parent is a TapChip, just a defensive code
        if let nonNullClickHandler = clickHandler {
            // All good, then we define a tap gesture to fire the handler
            self.callback = {
                
                if let parentChip:TapChip = self.parentChip {
                    nonNullClickHandler(parentChip)
                }
            }
        }
    }
    
}


