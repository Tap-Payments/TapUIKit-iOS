//
//  TapGoPayCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 29/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import class UIKit.UIImage
/// This class is responsible for creating a viewmodel for feeding up the tap goPay chip view, which has a static left accessory view and static body content
@objc public class TapGoPayCellViewModel:TapChipCellViewModel {
    internal typealias GoPayCellConfigurator = CollectionCellConfigurator<TapGoPayCollectionViewCell, TapGoPayCellViewModel>
    /**
        Creates a recent card view model to be used to draw data inside a recent card chip cell
    - Parameter leftAccessoryImage: The image you want to show as the left accessory. Default is nil, in this case will be the card brand image
    - Parameter bodyContent: The string content of the chip, in this case, the card number
     */
    @objc public override init() {
        super.init()
        // Based on given images for accessories we determine which of them can be added
        configureAccessoryViews(with: UIImage.loadLocally(with: "tapLogo", from: type(of: self)))
        self.bodyContent = "goPay"
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
        return GoPayCellConfigurator.init(item: self)
    }
}
