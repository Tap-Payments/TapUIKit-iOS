//
//  TapCardRecentCardCellViewModell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UIImage

/// This class is responsible for creating a viewmodel for feeding up the tap recent card chip view, which has a configurable left accessory and card number contenr
@objc public class TapCardRecentCardCellViewModel:TapChipCellViewModel {
    
    internal typealias CardCellConfigurator = CollectionCellConfigurator<TapRecentCardCollectionViewCell, TapCardRecentCardCellViewModel>
    
    /**
        Creates a recent card view model to be used to draw data inside a recent card chip cell
    - Parameter leftAccessoryImage: The image you want to show as the left accessory. Default is nil, in this case will be the card brand image
    - Parameter bodyContent: The string content of the chip, in this case, the card number
     */
    @objc public convenience init(leftAccessoryImage:UIImage? = nil, bodyContent:String = "") {
        self.init()
        // Based on given images for accessories we determine which of them can be added
        configureAccessoryViews(with: leftAccessoryImage)
        self.bodyContent = bodyContent
    }
    
    /**
        Based on given images for the accessories, the method decides which of them will be shown
    - Parameter leftAccessoryImage: The image you want to show as the left accessory. Default is nil, in this case will be the card brand image
     */
    internal func configureAccessoryViews(with leftAccessoryImage:UIImage? = nil) {
        if let nonNullLeftAccessoryImage = leftAccessoryImage {
            self.leftAccessory = TapChipAccessoryView(image: nonNullLeftAccessoryImage)
        }
    }
    
    
    override func convertToCellConfigrator() -> CellConfigurator {
        return CardCellConfigurator.init(item: self)
    }
    
}
