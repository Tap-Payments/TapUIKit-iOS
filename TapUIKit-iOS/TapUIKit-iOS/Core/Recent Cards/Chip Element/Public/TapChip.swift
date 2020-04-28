//
//  Chip.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 27/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
/// A class that represents the Chip view of right accessory, left accessory and a labe;l
@objc public class TapChip:UIStackView {
    
    /// The right accessory uiimageview of the chip element
    lazy internal var rightAccessory:UIImageView = UIImageView()
    /// The left accessory uiimageview of the chip element
    lazy internal var leftAccessory:UIImageView = UIImageView()
    /// The content label of the chip element
    lazy internal var contentLabel:UILabel = UILabel()
    /// The stackview holder for the UI elements
    lazy internal var stackView:UIStackView = UIStackView()
    /// The spacing between the elements inside the chip ui and the left and right paddings
    lazy internal var itemsSpacing:CGFloat = 7
    
    
    required init(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
    }
    
}
