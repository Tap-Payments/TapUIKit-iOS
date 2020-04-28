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
     - Parameter themeDictionary: Defines the theme needed to be applied as a dictionary if any. Default is nil
     - Parameter jsonTheme: Defines the theme needed to be applied as a json file file name if any. Default is nil
     */
    @objc public func setup(contentString:String, rightAccessory:TapChipAccessoryView? = nil, leftAccessory:TapChipAccessoryView? = nil, themeDictionary:NSDictionary? = nil,jsonTheme:String? = nil) {
        
        // Asssign and attach the internal values with the given ones
        self.contentLabel.text = contentString
        self.rightAccessory = rightAccessory
        self.leftAccessory = leftAccessory
        // Decide which theme we will use
        themeSelector(themeDictionary: themingDictionary, jsonTheme: jsonTheme)
        // Kick off the layout inflation
        setupViews()
    }
    
    /**
    Method used to decide which theme will we use from a given dict, given json or the default one
    - Parameter themeDictionary: Defines the theme needed to be applied as a dictionary if any. Default is nil
    - Parameter jsonTheme: Defines the theme needed to be applied as a json file file name if any. Default is nil
    */
    internal func themeSelector(themeDictionary:NSDictionary? = nil,jsonTheme:String? = nil) {
        applyingDefaultTheme = false
        if let nonNullCustomDictionaryTheme = themeDictionary {
            // The user provided a custom dictionary theme
            themingDictionary = nonNullCustomDictionaryTheme
        }else if let nonNullCustomJsonTheme = jsonTheme {
            // The user provided a custom json theme file
            TapThemeManager.setTapTheme(jsonName: nonNullCustomJsonTheme)
            themingDictionary = TapThemeManager.currentTheme
        }else {
            // Then we se the default theme
            applyingDefaultTheme = true
            applyDefaultTheme()
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // In here we do listen to the trait collection change event :), this leads to changing the theme based on dark or light mode activated by the user at run time.
        guard applyingDefaultTheme else {
            // We will do nothing, if the view is using a customised given theme as it should be handled by the caller.
            return
        }
        // If the view is set to use the default theme, hence, we change the theme based on the dark or light mode is activated
        applyDefaultTheme()
        applyTheme()
    }
    
    
    /// Internal helper method to apply the default theme
    internal func applyDefaultTheme() {
        // Check if the file exists
        let bundle:Bundle = Bundle(for: type(of: self))
        // Based on the current display mode, we decide which default theme file we will use
        let themeFile:String = (self.traitCollection.userInterfaceStyle == .dark) ? "DefaultDarkTheme" : "DefaultLightTheme"
        // Defensive code to make sure all is loaded correctly
        guard let jsonPath = bundle.path(forResource: themeFile, ofType: "json") else {
            print("TapThemeManager WARNING: Can't find json 'DefaultTheme'")
            return
        }
        // Check if the file is correctly parsable
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
            let jsonDict = json as? NSDictionary else {
                print("TapThemeManager WARNING: Can't read json 'DefaultTheme' at: \(jsonPath)")
                return
        }
        themingDictionary = jsonDict
        applyingDefaultTheme = true
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
        setupStackView()
        self.addSubview(stackView)
        
        // If there is a left accessory we add it first
        if let nonNullLeftAccessory = leftAccessory {
            nonNullLeftAccessory.parentChip = self
            stackView.addArrangedSubview(nonNullLeftAccessory)
        }
        
        // Define that we want the card nummber to fill as much width as possible
        contentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(contentLabel)
        
        // If there is a right accessory we add it last
        if let nonNullRightAccessory = rightAccessory {
            nonNullRightAccessory.parentChip = self
            stackView.addArrangedSubview(nonNullRightAccessory)
        }
        
    }
    
    /// This method defines the needed attribtes and values for the horizontal stackview used to gather the chip ui subviews
    internal func setupStackView() {
        // horizontal type
        stackView.axis = .horizontal
        // Center items vertically
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        // Set the spacing between items
        stackView.spacing = itemsSpacing
        // Fill the stack view width with the elements
        stackView.distribution = .fillProportionally
        
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: itemsSpacing, bottom: 0, right: itemsSpacing)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    /// This method is responsible for setting up the layout constraint to correctly layout the views of the Chip
    internal func setupConstraints() {
        
        // view constraints
        self.snp.remakeConstraints { (make) in
            make.height.equalTo(CGFloat(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.chipHeight")?.floatValue ?? 0))
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
        // We will need the spacing in trailing and leading (which are the margins around the stack view)
        var neededWidth = 2*itemsSpacing
        // The two spaces always will be there before first element and after last element
        neededWidth += 2*itemsSpacing
        
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
    
    /// This method is responsible for applying the correct theme and setting and matching the theme attributes
    @objc public func applyTheme(themingDict:NSDictionary? = nil) {
        // Defensive coding to make sure theme is alredy selected before actually applying one
        if let nonNullThemingDict = themingDict {
            self.themingDictionary = nonNullThemingDict
            applyingDefaultTheme = false
        }
        guard let nonNullThemingDictionary = themingDictionary else {return}
        TapThemeManager.setTapTheme(themeDict: nonNullThemingDictionary)
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
        self.layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).commonAttributes.\(shadowPath).opacity")?.floatValue ?? 0)
        self.layer.masksToBounds = false
    }
    
}
