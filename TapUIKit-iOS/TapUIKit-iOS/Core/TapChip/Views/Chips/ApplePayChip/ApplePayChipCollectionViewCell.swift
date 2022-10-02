//
//  ApplePayChipCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

@objc class ApplePayChipCollectionViewCell: GenericTapChip {
    
    // MARK:- Variables
    
    /// Reference to the saved card icon image view
    @IBOutlet weak var applePayContainerView: UIView!
    /// Reference to the saved card icon image view
    @IBOutlet weak var applePayTitle: UILabel!
    //    private var tapApplePayButton:TapApplePayButton?
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// view model that will control the cell view
    @objc public var viewModel:ApplePayChipViewCellModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            // We reload the cell data from the view model
            reload()
        }
    }
    
    // MARK:- Internal methods
    
    func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:ApplePayChipViewCellModel = viewModel as? ApplePayChipViewCellModel else { return }
        self.viewModel = correctTypeModel
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
    
    override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .ApplePayChip
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    // Mark:- Init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
    /// Holds the logic needed to display and fetch all the requied data and displays it inside the cell view
    func reload() {
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
}


// Mark:- Theme methods
extension ApplePayChipCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let shadowPath:String = isSelected ? "selected" : "unSelected"
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")
        
        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).\(shadowPath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.radius")?.floatValue ?? 0)
        layer.tap_theme_borderColor = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderColor")
        layer.tap_theme_borderWidth = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderWidth")
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        let applePayLogo = NSAttributedString(string: "", attributes: [ NSAttributedString.Key.foregroundColor: TapThemeManager.colorValue(for: "\(themePath).appleLogoTitleColor") ?? .white, NSAttributedString.Key.font: TapThemeManager.fontValue(for: "\(themePath).appleLogoTitleFont",shouldLocalise: false)!])
        
        
        let applePayTitle = NSAttributedString(string: "Pay", attributes: [ NSAttributedString.Key.foregroundColor: TapThemeManager.colorValue(for: "\(themePath).applePayTitleColor") ?? .white, NSAttributedString.Key.font: TapThemeManager.fontValue(for: "\(themePath).applePayTitleFont",shouldLocalise: false)!])
        
        let setupApplePayTitle = NSAttributedString(string: "Setup ", attributes: [ NSAttributedString.Key.foregroundColor: TapThemeManager.colorValue(for: "\(themePath).applePayTitleColor") ?? .white, NSAttributedString.Key.font: TapThemeManager.fontValue(for: "\(themePath).applePayTitleFont",shouldLocalise: false)!])
        
        let combination = NSMutableAttributedString()
        if(viewModel.applePayButtonType == .SetupApplePay) {
            combination.append(setupApplePayTitle)
        }
        combination.append(applePayLogo)
        combination.append(applePayTitle)
        
        self.applePayTitle.attributedText = combination
        
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}



extension ApplePayChipCollectionViewCell:GenericCellChipViewModelDelegate {
    
    func changedEditMode(to: Bool) {
        self.contentView.alpha = to ? 0.5 : 1
        self.isUserInteractionEnabled = !to
    }
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}
