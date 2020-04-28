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
import TapThemeManager2020
/// A class that represents the Chip view of right accessory, left accessory and a labe;l
@objc public class TapChip:UIView {
    
    /// The right accessory uiimageview of the chip element
    internal var rightAccessory:TapChipAccessoryView?
    /// The left accessory uiimageview of the chip element
    internal var leftAccessory:TapChipAccessoryView?
    /// The main stack view that holds the inner components (card fields)
    internal lazy var stackView = UIStackView()
    /// The content label of the chip element
    lazy internal var contentLabel:UILabel = UILabel()
    /// The spacing between the elements inside the chip ui and the left and right paddings
    lazy internal var itemsSpacing:CGFloat = 7
    /// States if the view is using the default TAP theme or a custom one
    internal lazy var applyingDefaultTheme:Bool = true
    /// The current theme being applied
    internal var themingDictionary:NSDictionary?
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "chipUI"
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.backgroundColor = .clear
    }
    
    /**
     Method used to setup the TapChip ui element with the needed views
      - Parameter contentString: The text to be displayed inside the label content of the TapChip
      - Parameter rightAccessory: The right accessory you need to display if any, default is nil
      - Parameter leftAccessory: The left accessory you need to display if any, default is nil
     */
    @objc public func setup(contentString:String, rightAccessory:TapChipAccessoryView? = nil, leftAccessory:TapChipAccessoryView? = nil) {
        
        // Asssign and attach the internal values with the given ones
        self.contentLabel.text = contentString
        self.rightAccessory = rightAccessory
        self.leftAccessory = leftAccessory
        applyingDefaultTheme = true
        // Kick off the layout inflation
        setupViews()
    }
    
    /// The method that organises the steps needed to correctly draw the view and its subviews
    internal func setupViews() {
        addViews()
        applyTheme()
        setupConstraints()
    }
    
    /// Method responsible for adding the sbviews ibnside the TapChip element in order
    internal func addViews() {
        
        // Define the attributes needed for the stack view
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = itemsSpacing
        stackView.distribution = .fillProportionally
        self.addSubview(stackView)
        
        // If there is a left accessory we add it first
        if let nonNullLeftAccessory = leftAccessory {
            stackView.addArrangedSubview(nonNullLeftAccessory)
        }
        
        // Define that we want the card nummber to fill as much width as possible
        contentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(contentLabel)
        
        // If there is a right accessory we add it last
        if let nonNullRightAccessory = rightAccessory {
            stackView.addArrangedSubview(nonNullRightAccessory)
        }
        
    }
    
    
    /// This method is responsible for setting up the layout constraint to correctly layout the views of the Chip
    internal func setupConstraints() {
        
        // view constraints
        self.snp.remakeConstraints { (make) in
            make.height.equalTo(CGFloat(TapThemeManager.numberValue(for: "\(themePath).leftAccessory.width")?.floatValue ?? 0))
            make.width.equalTo(computeNeededWidth())
        }
        
        // StackView constraints
        stackView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Left accessory constraints
        if let nonNullLeftAccessory = leftAccessory {
            nonNullLeftAccessory.snp.remakeConstraints { (make) in
                make.height.width.equalTo(CGFloat(TapThemeManager.numberValue(for: "\(themePath).leftAccessory.width")?.floatValue ?? 0))
            }
        }
        
        // Right accessory constraints
        if let nonNullRightAccessory = rightAccessory {
            nonNullRightAccessory.snp.remakeConstraints { (make) in
                make.height.width.equalTo(CGFloat(TapThemeManager.numberValue(for: "\(themePath).rightAccessory.width")?.floatValue ?? 0))
            }
        }
        
    }
    
    /**
     This method calculates the needed width to show all the views needed inside the chip ui
     - Returns: The needed width in float to display all the views
     */
    internal func computeNeededWidth() -> CGFloat {
        // We will need the spacing in trailing and leading
        var neededWidth = 2*itemsSpacing
        
        // If the user has left accessory stated, then we need to calculate its width and spacing
        if let _ = leftAccessory {
            neededWidth += CGFloat(TapThemeManager.numberValue(for: "\(themePath).leftAccessory.width")?.floatValue ?? 0)
            neededWidth += itemsSpacing
        }
        
        // We need to calculate the size needed to display the content label given its font and text
        let size: CGSize = (contentLabel.text?.size(withAttributes: [NSAttributedString.Key.font : contentLabel.font!]))!
        neededWidth += size.width
        
        // If the user has right accessory stated, then we need to calculate its width and spacing
        if let _ = rightAccessory {
            neededWidth += itemsSpacing
            neededWidth += CGFloat(TapThemeManager.numberValue(for: "\(themePath).rightAccessory.width")?.floatValue ?? 0)
        }
        
        return neededWidth
    }
    
    /// This method is responsible for setting and matching the theme attributes
    internal func applyTheme() {
        
        matchThemeAttribtes()
        
    }
    
    /// This method matches the correct ui elements to its theme path inside the theme object
    internal func matchThemeAttribtes() {
        
        // Define the content label theme attributes
        contentLabel.tap_theme_textColor = ThemeUIColorSelector.init(keyPath: "\(themePath).contentLabel.textColor")
        contentLabel.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).contentLabel.textFont")
        
        // background color
        self.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).commonAttributes.backgroundColor")
        // The border color
        self.layer.tap_theme_borderColor = ThemeCgColorSelector.init(keyPath: "\(themePath).commonAttributes.borderColor")
        // The border width
        self.layer.tap_theme_borderWidth = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.borderWidth")
        // The border rounded corners
        self.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).commonAttributes.cornerRadius")
        
        // The shadow details
        showShadow()
        
        self.itemsSpacing = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.itemSpacing")?.floatValue ?? 0)
    }
    
    /**
     This method is used to show a shadow on the chip ui view
     - Parameter glowing: This will specify if you want to show the glowing shadow or the normal shadow. Default is false
     */
    @objc public func showShadow(glowing:Bool = false) {
        let shadowPath = (glowing) ? "glowingShadow" : "shadow"
        
        self.layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.\(shadowPath).radius")?.floatValue ?? 0)
        self.layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).commonAttributes.\(shadowPath).color")
        self.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.\(shadowPath).offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.\(shadowPath).offsetHeight")?.floatValue ?? 0))
        self.layer.shadowOpacity = 0//Float(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.shadow.opacity")?.floatValue ?? 0)
        self.layer.masksToBounds = false
    }
    
}
