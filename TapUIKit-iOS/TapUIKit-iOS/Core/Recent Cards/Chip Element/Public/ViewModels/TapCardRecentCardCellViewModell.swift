//
//  TapCardRecentCardCellViewModell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UIImage

/// This class is responsible for creating a viewmodel for feeding up the tap recent card chip view
@objc public class TapCardRecentCardCellViewModell:TapCellViewModel {
    
    /// The left accessory uiimageview of the chip element
    internal var leftAccessory:TapChipAccessoryView?
    /// The right accessory uiimageview of the chip element
    internal var rightAccessory:TapChipAccessoryView?
    /// The content label of the chip element
    internal lazy var bodyContent:String = ""
    
    /**
        Creates a recent card view model to be used to draw data inside a recent card chip cell
    - Parameter leftAccessoryImage: The image you want to show as the left accessory. Default is nil, in this case will be the card brand image
    - Parameter rightAccessoryImage: The image you want to show as the right accessory. Default is nil
    - Parameter bodyContent: The string content of the chip, in this case, the card number
     */
    @objc public convenience init(leftAccessoryImage:UIImage? = nil, rightAccessoryImage:UIImage? = nil, bodyContent:String = "") {
        self.init()
        // Based on given images for accessories we determine which of them can be added
        configureAccessoryViews(with: leftAccessoryImage, and: rightAccessoryImage)
        self.bodyContent = bodyContent
    }
    
    /**
        Based on given images for the accessories, the method decides which of them will be shown
    - Parameter leftAccessoryImage: The image you want to show as the left accessory. Default is nil, in this case will be the card brand image
    - Parameter rightAccessoryImage: The image you want to show as the right accessory. Default is nil
     */
    internal func configureAccessoryViews(with leftAccessoryImage:UIImage? = nil,and rightAccessoryImage:UIImage? = nil) {
        if let nonNullLeftAccessoryImage = leftAccessoryImage {
            self.leftAccessory = TapChipAccessoryView(image: nonNullLeftAccessoryImage)
        }
        if let nonNullRightAccessoryImage = rightAccessoryImage {
            self.rightAccessory = TapChipAccessoryView(image: nonNullRightAccessoryImage)
        }
    }
    
}
